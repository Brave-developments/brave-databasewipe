Config = {}

-- Framework Selection
Config.Framework = "qbcore" -- Options: "qbcore", "esx", "ox"

-- Command Details
Config.CleanCommand = "wipe_selected"
Config.CleanCommandInfo = "Wipes all data from phone and QB-related database tables."

-- Specific Tables to Wipe
Config.TablesToWipe = {
    -- QBCore-related tables
    "players",
    "playerskins",
    "inventories",
    -- "trunkitems",
    -- "gloveboxitems",
    "apartments",
    -- "stashitems",
     "sayer_gangs",
     "sayer_zones",
    -- Phone-related tables
    "phone_accounts",
    "phone_messages",
    "phone_contacts",
    "phone_notifies",
    "phone_chatrooms",
    "phone_chatroom_messages",
    "phone_favorite_contacts",
    "phone_metadata",
    "phone_gallery",
    "twitter_accounts",
    "twitter_tweets",
    "twitter_messages",
    "whatsapp_accounts",
    "whatsapp_chats",
    "whatsapp_status",
    "tiktok_users",
    "instagram_accounts",
    "instagram_posts",
    "instagram_messages"
}

-- Webhook Settings
-- Set your own Discord webhook here. Do NOT commit a real one to a public repo.
Config.WebhookURL = "" -- e.g. https://discord.com/api/webhooks/xxx/yyy
Config.WebhookUsername = "WipeBot"
Config.WebhookAvatar = "https://your-avatar-url.png"
Config.WebhookMessageTemplate = "Selected tables wiped successfully.\nTotal rows deleted: %d\nDetails:\n%s"

-- Maintenance Message
Config.KickMessage = "The server is performing maintenance. Season 2."

-- Database Library
Config.DatabaseLibrary = "oxmysql" -- Options: "oxmysql", "ghatmysql"
