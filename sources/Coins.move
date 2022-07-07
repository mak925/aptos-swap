module Sender::Coins {
    use Std::Signer;
    use Std::ASCII::string;
    use AptosFramework::Coin::{Self, MintCapability, BurnCapability};
    //use AptosFramework::TypeInfo;
    //use 0x1::Coin;

    /// Represents test USDT coin.
    struct USDT has key {}

    /// Represents test BTC coin.
    struct BTC has key {}

    /// Storing mint/burn capabilities for `USDT` and `BTC` coins under user account.
    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    /// Initializes `BTC` and `USDT` coins.
    public(script) fun register_coins(token_admin: signer) {
        let (btc_m, btc_b) =
            Coin::initialize<BTC>(&token_admin,
                string(b"Bitcoin"), string(b"BTC"), 8, true);
        let (usdt_m, usdt_b) =
            Coin::initialize<USDT>(&token_admin,
                string(b"Tether"), string(b"USDT"), 6, true);
        move_to(&token_admin, Caps<BTC> { mint: btc_m, burn: btc_b });
        move_to(&token_admin, Caps<USDT> { mint: usdt_m, burn: usdt_b });
    }

    /// Mints new coin `CoinType` on account `acc_addr`.
    public(script) fun mint_coin<CoinType>(token_admin: &signer, acc_addr: address, amount: u64) acquires Caps {
        let token_admin_addr = Signer::address_of(token_admin);
        assert!(
            exists<Caps<CoinType>>(token_admin_addr),
            9999
        );
        let caps = borrow_global<Caps<CoinType>>(token_admin_addr);
        let coins = Coin::mint<CoinType>(amount, &caps.mint);
        Coin::deposit(acc_addr, coins);
    }
    #[test(account=@0x04, account2=@0x2)]
    public(script) fun test_mint_coin() {//acquires Caps{
        use AptosFramework::TypeInfo;
        //use AptosFramework::ASCII::{String};
        //let addr = Signer::address_of(&account);
        //let addr2 = Signer::address_of(&account2);
        //print(addr);
        
        let type_info = TypeInfo::type_of<TypeInfo::TypeInfo>();
        assert!(TypeInfo::module_name(&type_info) == b"TypeInfo", 1);
        assert!(TypeInfo::struct_name(&type_info) == b"TypeInfo", 1);
        assert!(TypeInfo::account_address(&type_info) == @0x1, 1);

        //test type of BTC and USDT
        let coin_info = TypeInfo::type_of<BTC>();
        assert!(TypeInfo::module_name(&coin_info)==b"Coins", 1);
        assert!(TypeInfo::struct_name(&coin_info)==b"BTC", 1);
        assert!(TypeInfo::account_address(&coin_info) == @0xb2279c426e0d4bb29524ef1d420a370f16c958eb87bbe345dd056ad470e44a92, 1);

          let coin_info = TypeInfo::type_of<USDT>();
        assert!(TypeInfo::module_name(&coin_info)==b"Coins", 1);
        assert!(TypeInfo::struct_name(&coin_info)==b"USDT", 1);
        assert!(TypeInfo::account_address(&coin_info) == @0xb2279c426e0d4bb29524ef1d420a370f16c958eb87bbe345dd056ad470e44a92, 1);
        

        //register_coins(account);
        //mint coins to someone
        //mint_coin<Sender::Coins::BTC>(&account2, addr2, 100); 1 byte = 8 bits = 2^8 = (2^4)^2
        //get coins balance of account 2
        // assert!(
        //     is_coin_initialized<BTC>()==true,
        //     1
        // )
        // assert!(
        //   balance<BTC>(addr2)>10,
        //   1
        // );

        //assert!(
        //  get_message(addr) == ASCII::string(b"Hello, Blockchain"),
        //  ENO_MESSAGE
        //);
    }
}