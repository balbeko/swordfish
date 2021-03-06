require '/assets/lib/jquery.js'
require '/assets/forge.js'
require '/assets/models/keypair.js'

describe 'Keypair', ->
  beforeEach ->
    Keypair.ajax = @ajax = jasmine.createSpy('ajax')
    Keypair.localStorage = @local = {}

    @keypair = new Keypair(key)

  describe 'create', ->
    beforeEach ->
      spyOn(Keypair.prototype, 'unlock')
      spyOn(Keypair.prototype, 'savePublicKey')
      spyOn(Keypair.prototype, 'savePrivateKey')
      Keypair.create(key, 'testing')

    it 'unlocks the keypair', ->
      expect(Keypair.prototype.unlock).toHaveBeenCalledWith('testing')

    it 'saves the public key ', ->
      expect(Keypair.prototype.savePublicKey).toHaveBeenCalled()

    it 'saves the private key ', ->
      expect(Keypair.prototype.savePrivateKey).toHaveBeenCalled()

  describe 'savePublicKey', ->
    beforeEach ->
      @keypair.unlock('testing')

    it 'saves public key to server', ->
      @keypair.savePublicKey()
      expect(@ajax).toHaveBeenCalled()

      params = @ajax.mostRecentCall.args[0]
      expect(params.url).toEqual('/key')
      expect(params.data.replace(/\s/g, '')).toEqual(publicKey.replace(/\s/g, ''))

  describe 'savePrivateKey', ->
    it 'saves private key to local storage', ->
      @keypair.savePrivateKey()
      expect(@local['privateKey']).toEqual(key)

  describe 'load', ->
    describe 'when keypair is not in local storage', ->
      it 'returns falsy', ->
        expect(Keypair.load()).not.toBeTruthy()

    describe 'when private key is set', ->
      beforeEach -> @local['privateKey'] = key

      it 'returns keypair with public/private key', ->
        keypair = Keypair.load(key)
        expect(keypair).toBeTruthy()
        expect(keypair.privateKeyPem).toBe(key)

  describe 'unlock', ->
    describe 'with the correct password', ->
      it 'returns true', ->
        expect(@keypair.unlock('testing')).toBe(true)

      it 'sets public key', ->
        @keypair.unlock('testing')
        expect(@keypair.publicKey).toBeTruthy()
        expect(@keypair.publicKey.encrypt).toBeTruthy()

    describe 'with an incorrect password', ->
      it 'returns true', ->
        expect(@keypair.unlock('wrong password')).toBe(false)

  key =
      """
      -----BEGIN ENCRYPTED PRIVATE KEY-----
      MIICzzBJBgkqhkiG9w0BBQ0wPDAbBgkqhkiG9w0BBQwwDgQIcr+AY81p67ACAggA
      MB0GCWCGSAFlAwQBAgQQ+MZ40SX/K9W8nxetEKPfHQSCAoBSGqUKsTPXNX/qpAoD
      cn9DvWZcCUQpWiLCtuaYp8trh51/OG8dj2+Mwq/xFFH+qlDM/QZZ2lEUEHSiDDOi
      ojBxtGiIDEKsHKDt9RKXij1FhVfW8TLaTYNoIJS1CnU3L+MG0sEAMyiReKJgPaBO
      uDYZ5aSfscPQ2BElzjOAEciWCF7Tc+8rn32pf4yGL2hximTxBGSVDiQdefKFH32C
      sujw5yzkHBStU5J4nlMYax7+yG48SecpP+EaR2n3kVWfM6Y1y85RLsVX4Yw91d5c
      02q6/TUggAwHbAuBBC/3u6+S+sTXRqx+oXkRdw/0sGOAEUViDzwPBkiK01Tk44Uy
      VsyHHG4u/Hk0/lLspv++Ee9BL4+KIWjZImvnJ7t6f3UnwdA9nLp5wfrdf13F+ENW
      1C3Gv+stu6SPJkpmo15BrXkM5gJtFrDn35kqGmvT+YA0TfRG8FI46LbwjbUDJhQ9
      S/g9Ks0Ps4MoyZpzi+3QD7DyxcnZ1wRGsPtTgIK4XKqQDTxvboe7/6d/D7TLRLcS
      99GuC7QfcfH6O0yH4C1NJ/6qtphY8yLNsodg61qNd1CL/tgpEzDWaDWngMg8To0h
      4elzhixvU9baXvTuQFvyCLlkh5AGCOJgqZChWkR64G+izvodUfjEggDpKfjEcNKy
      wITPbTHg0x6ibl72XGXiCU8+D4baxvThniwdMJAEWqmB3+2cvlU6dHkQzRxZHBEM
      dXzdv9xtiQfkuiMEyaYS7+72/GQ2ghSdZBUxB0qqq5ZbCz4AGLc/nGeP+DH6q57u
      ws8SDVgntQ9CB3mFaCyQQbRPhxcq1mNEnuJkDrZfrL8S7Nmi7anWPccTnZJ+97Qr
      yu9t
      -----END ENCRYPTED PRIVATE KEY-----
      """

  publicKey =
    """
    -----BEGIN PUBLIC KEY-----
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCAXY6jq67YAXSzlZtpwO0xe3/k
    ZAEfW7roIdCQEDWGneUdnwer+EfkTA/7wQnZxq993x7DzhaWHeUnanFFkjFn+mDb
    lOTowPaLWl9CYo7JLCRY3hSgT9qci2VcBCqIsP7JJAdS/PGmKMNDZufnblqlfzfU
    2shYSEmynVDgiDQITQIDAQAB
    -----END PUBLIC KEY-----
    """
