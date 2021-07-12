{
  "version": 0.0,
  "Resources": [
    {
      "myLambdaFunction": {
        "Type": "AWS::Lambda::Function",
        "Properties": {
          "Name": "myLambdaFunction",
          "Alias": "MyAlias1",
          "CurrentVersion": "1",
          "TargetVersion": "2"
        }
      }
    }
  ]
}