-- Create a default table for the IR8 object
IR8 = {}

------------------------------------------------------------
-- Ticket Manager Configuration
------------------------------------------------------------
IR8.Config = {

    -- Enables development printing
    Debugging = false,

    -- Server framework
    -- If set to none, please check `shared/core.lua` for information on how to support core functions.
    Framework = "qb", -- "esx" | "qb" | "none"

    -- Event related vars
    ServerCallbackPrefix = GetCurrentResourceName() .. ":Server",
    ClientCallbackPrefix = GetCurrentResourceName() .. ":Client",

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
    AdminPermissions = { "ticket.admin" },

    -- Command information
    Commands = {

        -- Command to manage blips
        Tickets = "tickets",
        TicketsDescription = "View ticket system",
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