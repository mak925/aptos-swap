#[test_only]
module Sender::UserInfoTests {
    use Std::ASCII;
    use Std::Signer;

    use Sender::UserInfo;

    // this named parameter to the test attribute allows to provide a signer to the test function,
    // it should be named the same way as parameter of the function
    #[test(user_account = @0x45, dub_account = @0x78)]
    public(script) fun test_getter_setter(dub_account: signer) {
        // ASCII::string() function allows to create a `String` object from a bytestring
        let username = b"MyUser";
        UserInfo::set_username(&dub_account, username);

        let user_addr = Signer::address_of(&dub_account);
        // assert! macro for asserts, needs an expression and a failure error code
        assert!(UserInfo::get_username(user_addr) == ASCII::string(username), 1);
    }
}