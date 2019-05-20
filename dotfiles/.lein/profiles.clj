{:user {:plugin-repositories [["private-plugins" {:url "private url"}]]
        :dependencies [[pjstadig/humane-test-output "0.8.2"]]
        :injections [(require 'pjstadig.humane-test-output)
                     (pjstadig.humane-test-output/activate!)]
        :plugins [[lein-ancient "0.6.15"]
                  [lein-pprint "1.1.2"]
                  [com.jakemccrary/lein-test-refresh "0.24.1"]
                  [lein-autoexpect "1.9.0"]
                  [lein-auto "0.1.3"]
                  [lein-midje "3.2.1"]]
        :test-refresh {:notify-command ["terminal-notifier" "-title" "Tests" "-message"]
                       :quiet true
                       :changes-only true}}}
