/*jshint laxbreak: true */

if (typeof require != 'undefined') {
    print = require('sys').puts;
}

var alert = function (msg) {
    print('ALERT: ' + msg); 
};

var console = {
    _out: function (obj, name) {
        name = name || '';
        print(name + obj);
    },
    log: function (obj) {
        return console._out(obj);
    },
    debug: function (obj) {
        return console._out(obj,name="DEBUG: ");
    },
    info: function (obj) {
        return console._out(obj,name="INFO: ");
    },
    warn: function (obj) {
        return console._out(obj,name="WARN: ");
    },
    error: function (obj) {
        return console._out(obj,name="ERROR: ");
    }
};

// Import extra libraries if running in Rhino.
if (typeof importPackage != 'undefined') {
    importPackage(java.io);
    importPackage(java.lang);
}

var readSTDIN = (function() {
    // readSTDIN() definition for nodejs
    if (typeof process != 'undefined' && process.openStdin) {
        return function readSTDIN(callback) {
            var stdin = process.openStdin()
              , body = [];

            stdin.on('data', function(chunk) {
                body.push(chunk);
            });

            stdin.on('end', function(chunk) {
                callback(body.join('\n'));
            });
        };

    // readSTDIN() definition for Rhino
    } else if (typeof BufferedReader != 'undefined') {
        return function readSTDIN(callback) {
            // setup the input buffer and output buffer
            var stdin = new BufferedReader(new InputStreamReader(System['in'])),
                lines = [];

            // read stdin buffer until EOF (or skip)
            while (stdin.ready()){
                lines.push(stdin.readLine());
            }

            callback(lines.join('\n'));
        };

    // readSTDIN() definition for Spidermonkey
    } else if (typeof readline != 'undefined') {
        return function readSTDIN(callback) {
            var line
              , input = []
              , emptyCount = 0
              , i;

            line = readline();
            while (emptyCount < 25) {
                input.push(line);
                if (line) {
                    emptyCount = 0;
                } else {
                    emptyCount += 1;
                }
                line = readline();
            }

            input.splice(-emptyCount);
            callback(input.join('\n'));
        };
    }
})();

readSTDIN(function(body) {
	console.log(eval(body));
});
