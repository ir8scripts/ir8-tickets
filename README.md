# Ticket Manager

In-game all-in-one solution for ticket management for both ESX & QB Core FiveM servers.

Features:

- All in-game based
- Webhook Configuration
- Theme is configurable
- Permissions are configurable
- Categories included & are configurable
- Statuses are configurable (Color, Replies allowed, Label)
- Configurable command
- Players can provide the position, title, message, and category for tickets
- Players & Staff members can reply to tickets
- Players receive notifications (if online) when a reply or status is changed on their tickets.

If you need any support, feel free to reach out to us via our Discord: https://discord.gg/wzEYNCN7pH

### Version 1.0.2

- Fixed issue with debugging in NUI and NUI path if resource is renamed

### Version 1.0.1

- Fixed issue with getting player source with ESX

### Dependencies

- Supports both ESX and QBCore
- oxmysql
- ox_lib

### Database

Run the `__install/database.sql` file in your server's database.

### Drop the Resource

Download the main branch and drop the package into your resources folder and remember to `ensure ir8-tickets` after `ox_lib` and `oxmysql`

### Configuration

```
------------------------------------------------------------
-- Ticket Manager Configuration
------------------------------------------------------------
IR8.Config = {

    -- Enables development printing
    Debugging = true,

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
```

### Webhook Configuration

You can set your webhook configuration from server/main.lua at the top of the file.

### Renaming the Resource

If you rename the resource folder, make sure you set the following configuration variables to match the folder name:

```
-- Event related vars
ServerCallbackPrefix = "ir8-tickets:Server", -- Change this if you rename the resource folder
ClientCallbackPrefix = "ir8-tickets:Client", -- Change this if you rename the resource folder
```

If you are renaming the database tables, be sure to update the configuration to reflect those changes:

```
-- Table definitions
DatabaseTables = {

    -- Where general ticket information is stored
    Tickets = "ir8_ticket",

    -- Where ticket messages are stored
    Messages = "ir8_ticket_message"
},
```