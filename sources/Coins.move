//
// this code is extends https://github.com/pontem-network/liquidswap-lp/blob/main/sources/Coins.move
//
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
    public(script) fun register_coins(token_admin: &signer) {
        let (btc_m, btc_b) = 
            Coin::initialize<BTC>(token_admin,
                string(b"Bitcoin"), string(b"BTC"), 8, true);
        let (usdt_m, usdt_b) =
            Coin::initialize<USDT>(token_admin,
                string(b"Tether"), string(b"USDT"), 6, true);
        move_to(token_admin, Caps<BTC> { mint: btc_m, burn: btc_b });
        move_to(token_admin, Caps<USDT> { mint: usdt_m, burn: usdt_b });
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

    // public fun swap<CoinType1, CoinType2>(token_admin_addr, user: &signer, ) acquires Caps{
    //     let caps = borrow_global<Caps<CoinType>>(token_admin_addr);
    // }
  
    #[test(token_admin=@Sender, other=@0x782)]
    public(script) fun test_mint_coin(token_admin:signer, other:signer) acquires Caps {//acquires Caps{
        use AptosFramework::TypeInfo;
        use AptosFramework::Coin;
        //use AptosFramework::ASCII::{String};
        //let addr = Signer::address_of(&token_admin);
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
        assert!(TypeInfo::account_address(&coin_info) == @Sender, 1);

        let coin_info = TypeInfo::type_of<USDT>();
        assert!(TypeInfo::module_name(&coin_info)==b"Coins", 1);
        assert!(TypeInfo::struct_name(&coin_info)==b"USDT", 1);
        assert!(TypeInfo::account_address(&coin_info) == @Sender, 1);
        
        // 
        // NOTE: this function used to take in token_admin and not &token_admin. In the former case, 
        // we're not able to use &token_admin anymore after this...but we want to use it to test 
        //
        register_coins(&token_admin); //init coins and move caps to token_admin

        let addr = Signer::address_of(&token_admin);
        let other_addr = Signer::address_of(&other);

        Coin::register<BTC>(&token_admin);
        Coin::register<BTC>(&other);

        assert!(
            Coin::is_account_registered<BTC>(addr)==true, 100
        );

        //mint coins to someone (in this case token admin)
        mint_coin<BTC>(&token_admin, addr, 100);

        assert!(
            Coin::balance<BTC>(addr)==100,
            2
        );

        assert!(Coin::balance<BTC>(other_addr)<100,
            2)
    }
}