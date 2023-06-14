require 'pstore'
require 'bcrypt'

$db = PStore.new('users')

def userexists? user
  $db.transaction(true) do
    $db[user] != nil
  end
end

def createuser user, pass
  hash = BCrypt::Password.create(pass)

  $db.transaction do
    $db[user] = pass
  end
end

def login user, pass
  hash = BCrypt::Password.create(pass)
  storedhash = $db.transaction {$db[user]}

  hash == storedhash
end
