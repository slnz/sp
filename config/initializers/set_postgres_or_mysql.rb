$postgres = Rails.configuration.database_configuration[Rails.env]["adapter"] == "postgresql"
$mysql = !$postgres
