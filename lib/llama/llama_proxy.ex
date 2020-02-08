defmodule Llama.Proxy do
    def send_messages(aggregateLogs, aggregateStats) do
        final_messages = Enum.reduce(aggregateLogs, [], fn {sender, rec_ob}, outer_acc -> 
            flat_recs = Enum.reduce(rec_ob, [], fn {receiver, log}, inner_acc -> 
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
    end
end