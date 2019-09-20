import requests
import datetime
import json

from_date = datetime.datetime(2019, 8, 1)
to_date = datetime.datetime(2019, 8, 18)
numdays = int((to_date - from_date).days) + 1
date_list = [(to_date - datetime.timedelta(days=x)) for x in range(0, numdays)]

def format_date(restore_date):
    return restore_date.strftime('%Y.%m.%d')

def indices(restore_date):
    formatted_date = format_date(restore_date)
    return 'your_index_prefixes-{formatted_date}'.format(formatted_date=formatted_date)

def restore(restore_date):
    payload = {
        'indices': indices(restore_date),
         'rename_pattern': 'some_prefix-(.+)',
         'rename_replacement': 'a_new_prefix-$1'
    }
    headers = {
        'Content-Type': "application/json",
        'Connection': "keep-alive"
        }

    endpoint = '{protocol}://{host}:{port}/_snapshot/gcs3/snapshot-{a}/_restore'.format(a=format_date(restore_date))
    print('Endpoint: ' + endpoint)
    print('Payload:\n' + json.dumps(payload))
    r = requests.post(endpoint, data = json.dumps(payload), headers = headers)
    print('Response: \n' + str(r.json()))

for the_date in date_list:
    restore(the_date)
