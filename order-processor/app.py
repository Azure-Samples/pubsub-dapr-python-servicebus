from flask import Flask, request, jsonify
from cloudevents.http import from_http
import json
import os

app = Flask(__name__)
app_port = os.getenv('APP_PORT', '5001')
pubsub_name = 'orderpubsub'
pubsub_topic = 'orders'

# Register Dapr pub/sub subscriptions
@app.route('/dapr/subscribe', methods=['GET'])
def subscribe():
    subscriptions = [{
        'pubsubname': pubsub_name,
        'topic': pubsub_topic,
        'route': pubsub_topic
    }]
    print('Dapr pub/sub is subscribed to: ' + json.dumps(subscriptions))
    return jsonify(subscriptions)


# Dapr subscription in /dapr/subscribe sets up this route
@app.route('/' + pubsub_topic, methods=['POST'])
def orders_subscriber():
    event = from_http(request.headers, request.get_data())
    print('Subscriber received : %s' % event.data['orderId'], flush=True)
    return json.dumps({'success': True}), 200, {
        'ContentType': 'application/json'}


app.run(port=app_port)
