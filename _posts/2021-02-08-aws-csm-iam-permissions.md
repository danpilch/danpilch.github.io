---
layout: post
title: AWS CSM - Figuring out what permissions your app really needs
last_updated: 2021-02-09
categories: community
---

I know the feeling all too well, trying to find the right balance of IAM permissions
without opening up your policy to `["ec2:*"]`. Figuring out every permission your
application requires can be an arduous process but there is a better way.

## AWS Client Side Monitoring (CSM)

CSM enables sending metrics via UDP connection to a CSM agent. The agent could
be anything, in this example I will use [nc](https://linux.die.net/man/1/nc).

You can enable CSM with your SDK of choice with:

```bash
export AWS_CSM_ENABLED=true
export AWS_CSM_PORT=31000
export AWS_CSM_HOST=127.0.0.1
```

Or by editing your `~/.aws/config` file:

```ini
[default]
default_region = us-west-2
csm_enabled = true
```

You can use the `awscli` or with an SDK for example the [go sdk](https://docs.aws.amazon.com/sdk-for-go/api/aws/csm/)

Once you've configured your sdk/cli, you can start `nc` listening on the default
host and port:

```bash
nc -kluvw 0 127.0.0.1 31000
```

Now you can invoke an aws api call, I'll use the `awscli`:

```bash
aws ec2 describe-instances
```

If we look at the `nc` in terminal:

```json
{
  "Version": 1,
  "ClientId": "",
  "Type": "ApiCallAttempt",
  "Service": "EC2",
  "Api": "DescribeInstances",
  "Timestamp": 1612776146962,
  "AttemptLatency": 9206,
  "Fqdn": "ec2.us-west-2.amazonaws.com",
  "UserAgent": "aws-cli/1.18.155 Python/3.8.7 Darwin/19.6.0 botocore/1.18.14",
  "AccessKey": "",
  "Region": "us-west-2",
  "HttpStatusCode": 200,
  "XAmznRequestId": "08550f64-cd15-4dac-870e-3b5bd59a010b"
}
```

We're interested in:
```json
"Service": "EC2", "Api": "DescribeInstances"
```
From this we can surmise we require `EC2:DescribeInstances`.

### Realtime IAM  Policy Generation

I found a great application called [iamlive](https://github.com/iann0036/iamlive) which can build a policy in realtime from `csm` requests. Check it out!
