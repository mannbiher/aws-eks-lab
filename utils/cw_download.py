import sys
import boto3


client = boto3.client('logs')


def process_records(records):
    for record in records:
        print(record['timestamp'], record['message'])


def get_logs(loggroup, streamname):
    last_token, next_token = None, None
    while True:
        response = client.get_log_events(
            logGroupName=loggroup,
            logStreamName=streamname,
            startFromHead=True #|False
        )
        if last_token is not None and last_token == next_token:
            return
        if response.get('events'):
            process_records(response['events'])
        last_token = next_token
        next_token = response.get('nextForwardToken')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('loggroup and streamname are required.')
        exit(1)
    loggroup = sys.argv[1]
    streamname = sys.argv[2]
    get_logs(loggroup, streamname)
