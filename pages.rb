module Pages
  def self.getlocals(page, params)
    case page
    when 'err'
      msgs = ['Credenciais inválidas', 'Esta conta já existe', 'Esta conta não existe', 'Mensagem longa demais ou inválida']
      code = params['code'].to_i-1
      {msg: msgs[code]}
    when 'main'
      newusr = params['newusr'] != nil
      {newusr: newusr}
    when 'chatroom'
      onlineusr = params['online']
      {onlineusr: onlineusr}
    end
  end
  
  def self.show(page, params)
    filename = "views/#{page}.erb"
    content = File.read(filename)

    locals = getlocals(page, params)

    return content, locals
  end
end
