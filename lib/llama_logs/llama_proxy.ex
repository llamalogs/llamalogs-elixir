defmodule LlamaLogs.Proxy do
    def send_messages() do
        %{aggregate_logs: aggregate_logs, aggregate_stats: aggregate_stats} = LlamaLogs.LogStore.get_and_clear_logs()
        send_logs(aggregate_logs)
        send_stats(aggregate_stats)
        send_data(aggregate_logs, aggregate_stats)
    end

    def send_data(aggregate_logs, aggregate_stats) do 
        formatted_logs = format_logs(aggregate_logs)

        formatted_stats = Enum.reduce(aggregate_stats, [], fn {_sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {_receiver, stat}, inner_acc -> 
                [stat | inner_acc]
            end)
            outer_acc ++ flat_recs
        end) 

        if (length(formatted_logs) != 0 || length(formatted_stats) != 0) do
            account_key = case true do
                length(formatted_logs) != 0 -> 
                    first_log = Enum.at(formatted_logs, 0)
                    first_log.account
                length(formatted_stats) != 0 -> 
                    first_stat = Enum.at(formatted_stats, 0)
                    first_stat.account
                _ -> ""
            end

            body = %{ time_logs: formatted_logs, time_stats: formatted_stats, account_key: account_key }
            string_body = Poison.encode!(body)
            url = "https://llamalogs.com/api/v0/timedata"
            result = HTTPoison.post url, string_body, [{"Content-Type", "application/json"}]
        end
    end

    def format_logs(aggregate_logs) do
        final_messages = Enum.reduce(aggregateLogs, [], fn {_sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {_receiver, log}, inner_acc -> 
                message = %{
                    sender: log[:sender] || "", 
					receiver: log[:receiver] || "",
					count: log[:total] || "",
					errorCount: log[:errors] || 0,
					log: log[:log] || "",
					errorLog: log[:errorLog] || "",
					clientTimestamp: :os.system_time(:millisecond),
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