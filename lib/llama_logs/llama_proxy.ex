defmodule LlamaLogs.Proxy do
    def collect_messages() do
        %{aggregate_logs: aggregate_logs, aggregate_stats: aggregate_stats} = LlamaLogs.LogStore.get_and_clear_logs()
        formatted_logs = format_logs(aggregate_logs)

        formatted_stats = Enum.reduce(aggregate_stats, [], fn {_sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {_receiver, stat}, inner_acc -> 
                [stat | inner_acc]
            end)
            outer_acc ++ flat_recs
        end)

        {formatted_logs, formatted_stats}
    end

    def send_messages() do
        {formatted_logs, formatted_stats} = collect_messages()
        send_data(formatted_logs, formatted_stats)
    end

    def send_data(formatted_logs, formatted_stats) do 
        if (length(formatted_logs) != 0 || length(formatted_stats) != 0) do
            log_length = length(formatted_logs)
            stat_length = length(formatted_stats)
            account_key = cond do
                log_length != 0 -> 
                    first_log = Enum.at(formatted_logs, 0)
                    first_log.account
                stat_length != 0 -> 
                    first_stat = Enum.at(formatted_stats, 0)
                    first_stat.account
                true -> ""
            end

            body = %{ time_logs: formatted_logs, time_stats: formatted_stats, account_key: account_key }
            string_body = Poison.encode!(body)

            url = case LlamaLogs.InitStore.is_dev_env do
                true -> "http://localhost:4000/api/v0/timedata"
                _ -> "https://llamalogs.com/api/v0/timedata"
            end

            HTTPoison.post url, string_body, [{"Content-Type", "application/json"}]
        end
    end

    def format_logs(aggregate_logs) do
        final_messages = Enum.reduce(aggregate_logs, [], fn {_sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {_receiver, log}, inner_acc -> 
                message = %{
                    sender: log[:sender] || "", 
					receiver: log[:receiver] || "",
					count: log[:total] || "",
					errorCount: log[:errors] || 0,
					message: log[:message] || "",
					errorMessage: log[:error_message] || "",
					graph: log[:graph] || "noGraph",
					account: log[:account] || "noAccount",
					initialMessageCount: log[:initialMessageCount] || 0
                }
                [message | inner_acc]
            end)

            outer_acc ++ flat_recs
        end) 

        final_messages
    end
end