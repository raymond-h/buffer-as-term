{exec} = require 'child_process'

{CompositeDisposable} = require 'atom'

nodeRun = (fn, params...) ->
    new Promise (resolve, reject) ->
        fn params..., (err, rets...) ->
            return reject err if err

            if rets.length <= 1
                resolve rets[0]

            else resolve rets

module.exports =
    disposables: null

    activate: (state) ->
        @disposables = new CompositeDisposable

        @disposables.add atom.commands.add 'atom-workspace',
            'buffer-as-term:run-command': =>
                @handleCommandUse()

    deactivate: ->
        @disposables.dispose()

    handleCommandUse: ->
        if editor = atom.workspace.getActiveTextEditor()
            selections = editor.getSelectedBufferRanges()
            range = selections[0]

            if range.isEmpty()
                range = editor.getBuffer().rangeForRow range.getRows()[0]

            @handleEditorRange editor, range

    handleEditorRange: (editor, range) ->
        @runCommand editor.getTextInBufferRange(range).trim()
        .then ([out]) ->
            editor.setTextInBufferRange range, out

    runCommand: (cmd) ->
        console.log "*** #{cmd}"
        nodeRun exec, cmd
