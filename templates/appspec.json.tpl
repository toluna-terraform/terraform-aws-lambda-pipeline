{
 	"version": 0.0,
 	"Resources": [{
 		"LambdaFunction": {
 			"Type": "AWS::Lambda::Function",
 			"Properties": {
 				"Name": "<LAMBDA_NAME>",
 				"Alias": "<LAMBDA_NAME>-latest",
 				"CurrentVersion": "1",
 				"TargetVersion": "2"
 			}
 		}
 	}],
 	"Hooks": [{
 			"BeforeAllowTraffic": "LambdaFunctionToValidateBeforeTrafficShift"
      },
      {
 			"AfterAllowTraffic": "LambdaFunctionToValidateAfterTrafficShift"
 		}
 	]
 }