const PACKET_HEADERS = {
  open: 0,
  close: 1,
  ping: 2,
  pong: 3,
  message: 4,
  upgrade: 5,
  noop: 6,
};

const DROPPED_MESSAGE_TYPES = ["AuthState", "Chat"];

const splitMessage = (message) => {
  return message.substring(message.indexOf(",") + 1);
};

const unpackMessage = (message) => {
  var extracted = splitMessage(message);
  var extractedData = JSON.parse(extracted);

  let internalMessage;

  if (extractedData[0] === "proxy-message") {
    var internalData = JSON.parse(extractedData[1]);
    internalMessage = internalData;
  } else {
    console.log("Unhanded message type:", extractedData[0]);
    internalMessage = null;
  }

  return internalMessage;
};

const filterByType = (message) => {
  if (message !== null) {
    const messageType = message.t;
    if (DROPPED_MESSAGE_TYPES.indexOf(messageType) >= 0) {
      return null;
    }

    return message;
  }
};

const messageHandler = (event) => {
  var eventData = event.data;
  var cc = eventData[0];
  if (cc != PACKET_HEADERS.message) {
    console.log("Discarding: " + eventData);
  } else {
    const message = unpackMessage(eventData);

    const filteredMessage = filterByType(message);

    window.postMessage(
      {
        clientMessage: filteredMessage,
        type: "interceptedMessage",
      },
      "*"
    );
  }
};

(function () {
  // eslint-disable-next-line no-undef
  var OrigWebSocket = window.WebSocket;
  var callWebSocket = OrigWebSocket.apply.bind(OrigWebSocket);
  var wsAddListener = OrigWebSocket.prototype.addEventListener;
  wsAddListener = wsAddListener.call.bind(wsAddListener);

  window.WebSocket = function WebSocket(url, protocols) {
    var ws;
    if (!(this instanceof WebSocket)) {
      // Called without 'new' (browsers will throw an error).
      ws = callWebSocket(this, arguments);
    } else if (arguments.length === 1) {
      ws = new OrigWebSocket(url);
    } else if (arguments.length >= 2) {
      ws = new OrigWebSocket(url, protocols);
    } else {
      // No arguments (browsers will throw an error)
      ws = new OrigWebSocket();
    }

    console.log("[*] Adding interceptor");
    wsAddListener(ws, "message", messageHandler);

    return ws;
  }.bind();
  window.WebSocket.prototype = OrigWebSocket.prototype;
  window.WebSocket.prototype.constructor = window.WebSocket;

  /*
    Intercepting the outgoing send does not appear to be working as
    expected, but should not be required at this time.
  */
  // var wsSend = OrigWebSocket.prototype.send;
  // console.log(wsSend);
  // wsSend = wsSend.apply.bind(wsSend);
  // OrigWebSocket.prototype.send = (data) => {
  //   console.log("Intercepted Send", data, arguments);
  //   return wsSend(this, arguments);
  // };
})();
