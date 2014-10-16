module DailyTestRoom
    module Webhooks
        require 'pry'
          def hookArrays
            list = [
              {
                regex: '(one does not simply) (.*)',
                id: 61579
              },
              {
                regex: '(.*,) (.* (everywhere|partout))',
                id: 347390
              },
              {
                regex: "(I DON'?T ALWAYS .*) (BUT WHEN I DO,? .*)".downcase,
                id: 61532
              },
              {
                regex: "(.*) - (.*) \\|batman",
                id: 438680
              },
              {
                regex: "(.*) - (.*) \\|wonka",
                id: 61582
              },
              {
                regex: "(.*) - (.*) \\|grumpycat",
                id: 405658
              },
              {
                regex: "(.*) - (.*) \\|bear",
                id: 100955
              },
              {
                regex: "(.*) - (.*) \\|patrick",
                id: 61581
              },
              {
                regex: "(.*) - (.*) \\|suits",
                id: 922147
              },
              {
                regex: "(NOT SURE IF .*) (OR .*)".downcase,
                id: 61520
              },
              {
                regex: "(AM I THE ONLY ONE AROUND HERE) (.*)".downcase,
                id: 259680
              },
              {
                regex: "(WHAT IF I TOLD YOU) (.*)".downcase,
                id: 100947
              },
              {
                regex: "(.*) (AND EVERYBODY LOSES THEIR MIND)".downcase,
                id: 1790995
              },
            ]

          end

          def hookList
            hooks = []
            hookArrays.each do |elem|
              hooks << {
                  url: "#{ENV['BASE_URI']}/hipchat/meme/#{elem[:id]}",
                  pattern: "#{elem[:regex]}",
                  event: 'room_message',
                  name: "meme #{elem[:id]}"
              }
            end
            hooks
          end
    end
end