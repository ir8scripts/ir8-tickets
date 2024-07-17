-- Create a default table for the IR8 object
IR8 = {}

------------------------------------------------------------
-- Blip Configuration
------------------------------------------------------------
IR8.Config = {

    -- Enables development printing
    Debugging = false,

    -- Server framework
    Framework = "qb", -- "esx" | "qb"

    -- Event related vars
    ServerCallbackPrefix = "ir8-tickets:Server", -- Change this if you rename the resource folder
    ClientCallbackPrefix = "ir8-tickets:Client", -- Change this if you rename the resource folder

    -- Ticket Configuration Variables
    TicketConfiguration = {

        -- Available Categories to choose
        Categories = {
            "General",
            "Bug Report",
            "Rule Break"
        },

        -- Available statuses to set tickets to
        -- Badge Type uses bootstraps badge classes (warning, info, success, error)
        Statuses = {
            {
                label = "Open",
                badgeType = "info",
                allowReplies = true -- Participants can reply if this is true and in this state
            },
            {
                label = "In Progress",
                badgeType = "warning",
                allowReplies = true -- Participants can reply if this is true and in this state
            },
            {
                label = "Closed",
                badgeType = "success",
                allowReplies = false -- Participants can reply if this is true and in this state
            }
        },

        -- Default status when a ticket is created, this should also exist in "Statuses"
        DefaultStatus = "Open",

        -- Disclaimer before submit button, set to false to hide.
        Disclaimer = "Please allow up to 24 hours for a staff member to process your ticket."
    },

    -- Table definitions
    DatabaseTables = {

        -- Where general ticket information is stored
        Tickets = "ir8_ticket",

        -- Where ticket messages are stored
        Messages = "ir8_ticket_message"
    },

    -- The following groups will have access to ticket administration
    -- This uses either ESX Groups or QB Core Permissions
    AdminPermissions = {
        'admin'
    },

    -- Command information
    Commands = {

        -- Command to manage blips
        Tickets = "tickets",
        TicketsDescription = "View ticket system",
    },

    -- Send discord notifications when blips are created / updated / deleted
    Discord = {

        -- Only sends webhooks if this is true
        WebhookEnabled = false,

        -- The webhook url to send the request to
        WebhookUrl = 'url',

        -- The author name of the webhook
        AuthorName = 'IR8 Ticket Manager'
    },

    -- Customize NUI Theme
    Theme = {

        Title = {
            Admin = "Ticket Manager",
            Player = "My Tickets"
        },

        Colors = {

            -- Background of the modal window
            Background = "rgba(19, 22, 24, 0.9)",

            -- Text color
            Text = "#ffffff"
        }
    }
}