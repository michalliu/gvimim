var ok = JSHINT(%s),
      i,
      error,
      errorType,
      nextError,
      errorCount,
      WARN = 'WARNING',
      ERROR = 'ERROR',
      messages=[];

    if (!ok) {
        errorCount = JSHINT.errors.length;
        for (i = 0; i < errorCount; i += 1) {
            error = JSHINT.errors[i];
            errorType = WARN;
            nextError = i < errorCount ? JSHINT.errors[i+1] : null;
            if (error && error.reason && error.reason.match(/^Stopping/) === null) {
                // If jslint stops next, this was an actual error
                if (nextError && nextError.reason && nextError.reason.match(/^Stopping/) !== null) {
                    errorType = ERROR;
                }
                messages.push([error.line, error.character, errorType, error.reason].join(":"));
            }
        }
    }
messages.join("\n");
