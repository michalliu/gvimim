var ok = JSHINT(%s),
	i,
	error,
	errorCount,
	messages=[];

if (!ok) {
    errorCount = JSHINT.errors.length;
    for (i = 0; i < errorCount; i += 1) {
        error = JSHINT.errors[i];
        if (error && error.reason && error.reason.match(/^Stopping/) === null) {
            messages.push([error.line, error.character, error.reason].join(":"));
        }
    }
}
messages.join("\n");
