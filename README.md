# **Selective Database Wipe Script**

## **Description**
A lightweight script for FiveM servers to selectively wipe specific database tables. Supports QBCore, ESX, and OX frameworks. Includes Discord webhook notifications, player kick messages, and server shutdown for maintenance.
## **Features**
- Selectively deletes data from specified database tables.
- Supports QBCore, ESX, and OX frameworks.
- Sends notifications to a Discord webhook after the wipe.
- Automatically kicks all players with a custom maintenance message.
- Initiates server shutdown after cleanup for maintenance.

---

## **How to Use**

### **1. Add the Resource**
Add the resource to your `server.cfg` file:
`ensure brave-database`


### **Configure the Script**
Modify the `config.lua` file:

- **Set the framework**:
`lua
  Config.Framework = "qbcore" -- Options: "qbcore", "esx", "ox"`

  ## **Define Tables to Wipe**
Specify the tables you want to wipe in `config.lua`:
`lua
Config.TablesToWipe = { "players", "phone_messages", "twitter_accounts" }```
`

Run the following command in the server console:
```wipe_selected```







