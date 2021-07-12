 {
   "Resources": {
      "MyLambdaFunction": {
         "Type": "AWS::Serverless::Function",
         "Properties": {
            "Handler": <HANDLER>,
            "Runtime": <RUNTIME>,
            "AutoPublishAlias": "live",
            "DeploymentPreference": {
               "Type": "Canary10Percent10Minutes",
               "Alarms": [
                  null,
                  null
               ],
               "Hooks": {
                  "PreTraffic": null,
                  "PostTraffic": null
               }
            }
         }
      }
   }
}