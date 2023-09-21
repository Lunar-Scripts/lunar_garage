Queries = {
    getGarage = 'SELECT * FROM %s WHERE owner = ? and type = ? and job is NULL',
    getGarageSociety = 'SELECT * FROM %s WHERE job = ? and type = ?',
    getImpound = 'SELECT * FROM %s WHERE owner = ? and type = ? and `stored` = 0 and job is NULL',
    getImpoundSociety = 'SELECT * FROM %s WHERE job = ? and type = ? and `stored` = 0',
    getStoredVehicle = 'SELECT * FROM %s WHERE (owner = ? or job = ?) and plate = ? and `stored` = ?',
    setStoredVehicle = 'UPDATE %s SET `stored` = ? WHERE plate = ?',
    getOwnedVehicle = 'SELECT * FROM %s WHERE (owner = ? or job = ?) and plate = ?',
    getVehicle = 'SELECT * FROM %s WHERE owner = ? and plate = ?',
    getVehicleStrict = 'SELECT * FROM %s WHERE owner = ? and plate = ? and job is NULL',
    transferVehiclePlayer = 'UPDATE %s SET owner = ? WHERE plate = ?',
    transferVehicleSociety = 'UPDATE %s SET job = ? WHERE plate = ?',
    withdrawVehicleSociety = 'UPDATE %s SET job = NULL WHERE plate = ?',
    getStoredGarage = 'SELECT * FROM %s WHERE owner = ? and type = ? and job is NULL and `stored` = 1'
}

local table
if Framework.name == 'es_extended' then
    table = 'owned_vehicles'
    Queries.setVehicleProps = 'UPDATE %s SET vehicle = ? WHERE plate = ?'
elseif Framework.name == 'qb-core' then
    table = 'player_vehicles'
    Queries.setVehicleProps = 'UPDATE %s SET mods = ? WHERE plate = ?'
else
    error(('%s framework isn\'t supported by default, you have to implement it yourself.'))
end

for key, query in pairs(Queries) do
    Queries[key] = query:format(table)
    if Framework.name == 'qb-core' then
        Queries[key] = Queries[key]:gsub('owner', 'citizenid')
    end
end
