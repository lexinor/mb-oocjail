function MBNotify(title, message, type, source)
    if Config.Notify == "okokNotify" then
        if not source then
            exports['okokNotify']:Alert(title, message, 10000, type)
        else
            TriggerClientEvent('okokNotify:Alert', source, title, message, 10000, type)
        end
    elseif Config.Notify == "ox" then
        if not source then
            lib.notify({
                title = locale("notify.title"),
                description = message,
                type = type,
                position = 'top',
                duration = 10000,
                style = {
                    backgroundColor = '#141414',
                    color = '#e60000'
                },
            })
        else
            TriggerClientEvent('ox_lib:notify', source, { type = 'inform', title = locale("notify.title"), description = message, duration = 10000, position = 'top', style = {
                backgroundColor = '#141414',
                color = '#e60000'
            }, })
        end
    else
        print("mb-gym: Your type of notify choice is not supported")
    end
end