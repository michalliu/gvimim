/*jshint laxbreak: true */
// internal function
var __print__ = (function() {
    var writer;
    if (typeof global != 'undefined' && global.console !== undefined) {
        writer = global.console.log;
        return function() {
            if (writer !== undefined) {
                writer.apply(global.console, arguments);
            }
        };
    }
    return function() {
        // dummy function
    };
})();

// define alert
var alert = function() {
        var arr = Array.prototype.slice.call(arguments);
        arr.splice(0, 0, "ALERT: ");
        __print__.apply(this, arr);
    };

// define console
var console = {
    _out: function() {
        __print__.apply(this, arguments);
    },
    log: function() {
        return console._out.apply(this, arguments);
    },
    debug: function(obj) {
        var arr = Array.prototype.slice.call(arguments);
        arr.splice(0, 0, "DEBUG: ");
        return console._out.apply(this, arr);
    },
    info: function(obj) {
        var arr = Array.prototype.slice.call(arguments);
        arr.splice(0, 0, "INFO: ");
        return console._out.apply(this, arr);
    },
    warn: function(obj) {
        var arr = Array.prototype.slice.call(arguments);
        arr.splice(0, 0, "WARN: ");
        return console._out.apply(this, arr);
    },
    error: function(obj) {
        var arr = Array.prototype.slice.call(arguments);
        arr.splice(0, 0, "ERROR: ");
        return console._out.apply(this, arr);
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
            var stdin = process.openStdin(),
                body = [];

            stdin.on('data', function(chunk) {
                body.push(chunk);
            });

            stdin.on('end', function(chunk) {
                callback(body.join(''));
            });
        };

        // readSTDIN() definition for Rhino
    } else if (typeof BufferedReader != 'undefined') {
        return function readSTDIN(callback) {
            // setup the input buffer and output buffer
            var stdin = new BufferedReader(new InputStreamReader(System['in'])),
                lines = [];

            // read stdin buffer until EOF (or skip)
            while (stdin.ready()) {
                lines.push(stdin.readLine());
            }

            callback(lines.join(''));
        };

        // readSTDIN() definition for Spidermonkey
    } else if (typeof readline != 'undefined') {
        return function readSTDIN(callback) {
            var line, input = [],
                emptyCount = 0,
                i;

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
            callback(input.join(''));
        };
    }
})();

readSTDIN(function(body) {
    try {
        console.log(eval(body));
    } catch (e) {
        console.log(e);
        if (typeof process != 'undefined') {
            process.exit(1);
        }
    }
});

