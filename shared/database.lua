-- Attaches to the IR8 table 
-- Can only call these from server side
IR8.Database = {

    -- Get rows
    GetTickets = function(admin, identifier)
        local rows = MySQL.query.await('SELECT * FROM `' .. IR8.Config.DatabaseTables.Tickets .. '` WHERE identifier = ? ORDER BY id DESC', {
            identifier
        })

        -- If admin, pull all tickets
        if admin then
            rows = MySQL.query.await('SELECT * FROM `' .. IR8.Config.DatabaseTables.Tickets .. '` ORDER BY id DESC')
        end

        return rows
    end,

    -- Get rows
    GetReplies = function(id)
        local rows = MySQL.query.await('SELECT * FROM `' .. IR8.Config.DatabaseTables.Messages .. '` WHERE ticket_id = ? ORDER BY id DESC', {
            id
        })

        return rows
    end,

    -- Get ticket data
    GetTicket = function(id)
        local data = MySQL.single.await('SELECT * FROM `' .. IR8.Config.DatabaseTables.Tickets .. '` WHERE id = ?', {
            id
        })

        if data then
            data.success = true
            data.replies = IR8.Database.GetReplies(data.id)
        else 
            data = { success = false }
        end

        return data
    end,

    -- Updates ticket status
    UpdateTicketStatus = function (id, status)

        local query = 'UPDATE `' .. IR8.Config.DatabaseTables.Tickets .. '` SET status = ? WHERE id = ?'
        local res = MySQL.query.await(query, {
            status,
            id
        })

        return { success = res and true or false }
    end,

    -- Creates a ticket reply
    CreateReply = function (identifier, name, data)

        local query = 'INSERT INTO `' .. IR8.Config.DatabaseTables.Messages .. '`(ticket_id, name, message, identifier) VALUES(?, ?, ?, ?)'
        local res = MySQL.insert.await(query, {
            data.ticket_id,
            name,
            data.message,
            identifier
        })

        return { success = res and true or false }
    end,

    -- Creates a ticket
    CreateTicket = function (identifier, name, data)

        local position = data.position and data.position or nil

        local query = 'INSERT INTO `' .. IR8.Config.DatabaseTables.Tickets .. '`(title, category, name, message, status, identifier, position) VALUES(?, ?, ?, ?, ?, ?, ?)'
        local res = MySQL.insert.await(query, {
            data.title,
            data.category,
            name,
            data.message,
            IR8.Config.TicketConfiguration.DefaultStatus,
            identifier,
            position
        })

        return { success = res and true or false, ticketId = res }
    end,
}
