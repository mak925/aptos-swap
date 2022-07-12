// Swap lets you swap any coin X for an equivalent amount of any other coin Y
// We assume that Coins has already been deployed to devnet using Sender
module Sender::Swap{
    use AptosFramework::Coin;
    
    use Std::Signer;
    
    struct SwapCoinStore<phantom CoinType> has key { coin: Coin::Coin<CoinType> }

    public(script) fun swap<A, B>(account: &signer, module_addr: address, a_amount: u64) acquires SwapCoinStore{
        let a_coin = Coin::withdraw<A>(account, a_amount);
        let b_amount = a_amount;
        let b_store = borrow_global_mut<SwapCoinStore<B>>(module_addr);
        let b_coin = Coin::extract<B>(&mut b_store.coin, b_amount);
        if (!Coin::is_account_registered<B>(Signer::address_of(account))){
            Coin::register<B>(account);
        };
        Coin::deposit<B>(Signer::address_of(account), b_coin);

        let a_store = borrow_global_mut<SwapCoinStore<A>>(module_addr);
        Coin::merge(&mut a_store.coin, a_coin);
    }

    public fun is_account_registered<CoinType>(account_addr: address): bool {
        exists<SwapCoinStore<CoinType>>(account_addr)
    }

    // admin can supply the SwapCoinStore with coins to start off with
    public(script) fun deposit<A>(admin: &signer, module_addr: address, amount: u64) acquires SwapCoinStore{
        let coin = Coin::withdraw<A>(admin, amount);
        let store;
        if (!is_account_registered<SwapCoinStore<A>>(module_addr)){
            let swapstore = SwapCoinStore<A>{
                coin: coin
            };
            move_to(admin, swapstore);
        } else{
            store = borrow_global_mut<SwapCoinStore<A>>(module_addr);
            Coin::merge(&mut store.coin, coin);
        };
    }

    //admin can withdraw tokens they supplied
    public(script) fun withdraw<B>(admin: &signer, module_addr: address, amount: u64) acquires SwapCoinStore{
         assert!(
            is_account_registered<SwapCoinStore<B>>(module_addr),
            118,
        );
        let store = borrow_global_mut<SwapCoinStore<B>>(module_addr);
        let coin = Coin::extract<B>(&mut store.coin, amount);
        let admin_addr = Signer::address_of(admin);
        Coin::deposit<B>(admin_addr, coin);
    }

    #[test(alice=@Sender, bob=@0x43)]
    public(script) fun test(alice:signer, bob:signer)acquires SwapCoinStore{ //, B:signer){
        use Std::Signer;
        use AptosFramework::Coin;
        use Sender::Coins::{register_coins, mint_coin, USDT, BTC};
        
        //use AptosFramework::TypeInfo;

        register_coins(&alice); // this actually inits USDT and BTC
        Coin::register<USDT>(&bob);
        Coin::register<USDT>(&alice);
        Coin::register<BTC>(&bob);
        Coin::register<BTC>(&alice);
        mint_coin<USDT>(&alice, Signer::address_of(&alice), 10);
        mint_coin<USDT>(&alice, Signer::address_of(&bob), 10);
        mint_coin<BTC>(&alice, Signer::address_of(&alice), 10);
        mint_coin<BTC>(&alice, Signer::address_of(&bob), 10);

        deposit<USDT>(&alice, @Sender, 10);
        deposit<BTC>(&alice, @Sender, 10);

        // bob interacts with swap contract, depositing BTC and taking alice's USDT
        swap<BTC, USDT>(&bob, @Sender, 5);

        assert!(Coin::balance<USDT>(Signer::address_of(&alice))==0, 1);
        assert!(Coin::balance<BTC>(Signer::address_of(&bob))==5, 1);
    }
}

// TODO, make it so that alice (the admin) doesn't have to deposit BTC before Bob can put in BTC 
// (since the SwapStore only gets defined in deposit), problem is bob can't create a new SwapStore and move_to the admin address
