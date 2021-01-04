class Crypto < ApplicationRecord

  INIT_VECTOR = (0..15).to_a.pack("C*")

  def encrypt(plain_text, key)
    secret_key =  [Digest::MD5.hexdigest(key)].pack("H*")
    cipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
    cipher.encrypt
    cipher.key = secret_key
    cipher.iv  = INIT_VECTOR
    encrypted_text = cipher.update(plain_text) + cipher.final
    (encrypted_text.unpack("H*")).first
  end

  def decrypt(cipher_text,key)
    secret_key =  [Digest::MD5.hexdigest(key)].pack("H*")
    encrypted_text = [cipher_text].pack("H*")
    decipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
    decipher.decrypt
    decipher.key = secret_key
    decipher.iv  = INIT_VECTOR
    decrypted_text = (decipher.update(encrypted_text) + decipher.final).gsub(/\0+$/, '')
    decrypted_text
  end

  def encrypt256(string, key)
    Base64.encode64(aes(key, string)).gsub /\s/, ''
  end

  def decrypt256(string, key)
    aes_decrypt(key, Base64.decode64(string))
  end

  def aes(key,string)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(key)
    cipher.iv = initialization_vector = cipher.random_iv
    cipher_text = cipher.update(string)
    cipher_text << cipher.final
    initialization_vector + cipher_text
  end

  def aes_decrypt(key, encrypted)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = Digest::SHA256.digest(key)
    cipher.iv = encrypted.slice!(0,16)
    d = cipher.update(encrypted)
    d << cipher.final
  end
end
