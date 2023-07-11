Queries = {
    getGarage = 'SELECT * FROM %s WHERE job = ? and type = ?',
    getGarageSociety = 'SELECT * FROM %s WHERE owner = ? and type = ? and job is NULL',
    getImpound = 'SELECT * FROM %s WHERE job = ? and type = ? and stored = 0',
    getImpoundSociety = 'SELECT * FROM %s WHERE owner = ? and type = ? and stored = 0 and job is NULL',
    getStoredVehicle = 'SELECT * FROM %s WHERE (owner = ? or job = ?) and plate = ? and stored = ?',
    setStoredVehicle = 'UPDATE %s SET stored = ? WHERE plate = ?',
    getVehicle = 'SELECT * FROM %s WHERE (owner = ? or job = ?) and plate = ?',
}

local table
if Framework.Name == 'es_extended' then
    table = 'owned_vehicles'
    Queries.setVehicleProps = 'UPDATE %s SET props = ? WHERE plate = ?'
elseif Framework.Name == 'qb-core' then
    table = 'player_vehicles'
    Queries.setVehicleProps = 'UPDATE %s SET mods = ? WHERE plate = ?'
else
    error(('%s framework isn\'t supported by default, you have to implement it yourself.'))
end

for key, query in pairs(Queries) do
    Queries[key] = query:format(table)
end
