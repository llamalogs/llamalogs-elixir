defmodule LlamaLogs.Proxy do
    def send_messages() do
        %{aggregate_logs: aggregate_logs, aggregate_stats: aggregate_stats} = LlamaLogs.LogStore.get_and_clear_logs()
        send_logs(aggregate_logs)
        send_stats(aggregate_stats)
    end

    def send_logs(aggregateLogs) do
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

        IO.inspect final_messages
        if (length(final_messages) != 0) do
            body = %{ time_logs: final_messages }
            string_body = Poison.encode!(body)
            url = "http://localhost:4000/api/timelogs"
            result = HTTPoison.post url, string_body, [{"Content-Type", "application/json"}]
            IO.inspect result
        end
    end

    def send_stats(aggregate_stats) do 
        final_messages = Enum.reduce(aggregate_stats, [], fn {_sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {_receiver, stat}, inner_acc -> 
                [stat | inner_acc]
            end)

            outer_acc ++ flat_recs
        end) 

        IO.inspect final_messages
        if (length(final_messages) != 0) do
            body = %{ time_stats: final_messages }
            string_body = Poison.encode!(body)
            url = "http://localhost:4000/api/timestats"
            result = HTTPoison.post url, string_body, [{"Content-Type", "application/json"}]
            IO.inspect result
        end
    end
end