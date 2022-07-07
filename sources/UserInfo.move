module Sender::UserInfo {
    use Std::ASCII::{String, string};
    use Std::Signer;

    struct UserProfile has key { username: String }

    // public fun get_specific_username(): String acquires UserProfile {
    //    //let addr: address = b"0x1234123412341234"; //address(string(b"0x8d9213e4d62033a610e658e6e8d9a1088728d58bed620e1c8e6e1ece12ae3c53"));
    //     borrow_global<UserProfile>(addr).username
    // }

    public fun get_username(user_addr: address): String acquires UserProfile {
        borrow_global<UserProfile>(user_addr).username
    }

    public(script) fun set_username(user_account: &signer, username_raw: vector<u8>) acquires UserProfile {
        // wrap username_raw (vector of bytes) to username string
        let username = string(username_raw);

        // get address of transaction sender
        let user_addr = Signer::address_of(user_account);
        // `exists` just to check whether resource is present in storage
        if (!exists<UserProfile>(user_addr)) {
          let info_store = UserProfile{ username: username };
          move_to(user_account, info_store);
        } else {
          // `borrow_global_mut` is to fetch mutable reference, we can change resources in storage that way
          let existing_info_store = borrow_global_mut<UserProfile>(user_addr);
          existing_info_store.username = username;
        }
    }
}