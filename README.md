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

If you need any support, feel free to reach out to us via our Discord: https://discord.gg/7NATz2Yw5a

### Dependencies

- Supports both ESX and QBCore
- oxmysql
- ox_lib

### Installation

`NOTE: As of v1.1.0, permissions system has changed to run off of ace permissions in your server.cfg`

- Run the `__install/database.sql` file in your server's database.
- Download the main branch and drop the package into your resources folder and remember to `ensure ir8-tickets` after `ox_lib` and `oxmysql`
- Add the permissions principal to your `server.cfg`:
- Be sure to open `/shared/config.lua` and set your framework and any other settings you may need to alter.

```
# Ticket Administration Ace
add_ace group.admin ticket.admin allow
```

### Webhook Configuration

You can set your webhook configuration from server/main.lua at the top of the file.