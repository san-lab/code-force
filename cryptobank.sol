pragma solidity ^0.4.0;

contract cryptobank {

    // Simplified version for Code Force Hackathon

    /* All numbers in cents of currency units */

    /* Common (global) public variables, types and constants */

    // The address that controls the bank.
    address public bank;

    // The fee rate.
    uint256 public feePerMillion;
    // The maximum fee charged.
    uint256 public maxFee;

    // The name of the bank.
    bytes32 public bankName;
    // The BIC code of the bank.
    bytes32 public bankCode;
    // The currency that balances of this bank are expressed in.
    bytes32 public currency;

    // Flag to indicate the system is paused for maintenance (set by the bank)
    bool    public pausedForMaintenance;


    // Currency tags:
    bytes32 constant USD = "USD";
    bytes32 constant EUR = "EUR";
    bytes32 constant PLN = "PLN";
    bytes32 constant GBP = "GBP";
    bytes32 constant MXN = "MXN";
    bytes32 constant BRL = "BRL";
    bytes32 constant CLP = "CLP";
    bytes32 constant CHF = "CHF";
    bytes32 constant AUD = "AUD";
    bytes32 constant NZD = "NZD";
    bytes32 constant JPY = "JPY";
    bytes32 constant CAD = "CAD";

    // Internal struct representing an account in the bank.
    struct Account {
        // To check if this account is still active (we don't delete accounts).
        bool active;
        // The address that created and owns this account.
        address owner;
        // The accounts ballance. Can be negative.
        int256 balance;
        // The maximum allowed overdraft of the account.
        uint256 overdraft;
        // Whether the account is blocked.
        bool blocked;
    }

    // An array of all the accounts.
    Account[] public accounts;

    // For efficiently finding the account of a certain address.
    mapping(address => uint256) public accountByOwner;

    /* Modifiers */

    // Only the bank can perform this function.
    modifier bankOnly {
        if (msg.sender != bank)
            throw;
        _;
    }

    // Check if the given account number corresponds to an existing account.
    modifier accountExists(uint256 account) {
        if (account >= accounts.length)
            throw;
        _;
    }

    // Only the owner of the account with given account number can perform this
    // function.
    modifier senderOnly(uint256 account) {
        if (msg.sender != accounts[account].owner)
            throw;
        _;
    }

    // Check if the account number corresponds to an unblocked account.
    modifier notBlocked(uint256 account) {
        if (accounts[account].blocked)
            throw;
        _;
    }

    // Check that the system is not paused for maintenance by the bank.
    modifier notPaused() {
        if(pausedForMaintenance)
            throw;
        _;
    }

    /* Constructor */

    function cryptobank(bytes32 _bankCode, bytes32 _currency) {
        bank = msg.sender;
        accounts.push(Account(true, bank, 0, 0, false)); // This will be the bank's P&L account (#0)
        feePerMillion = 1000;
        maxFee = 100;
        bankCode = _bankCode;
        currency = _currency;
    }

    /* ERC20 token standard functions */

    // Triggered when tokens are transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Unsupported
    //
    // Triggered whenever approve(address spender, uint256 value) is called.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Get the total token supply.
    function totalSupply() constant returns (uint256 totalSupply) {
        int256 totalAmount = 0;
        for(uint256 i = 0; i < accounts.length; i++) {
            totalAmount += accounts[i].balance;
        }
        return uint256(totalAmount);
    }

    // Get the account balance of another account with address owner.
    function balanceOf(address owner) constant returns (uint256 balance) {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(owner == accounts[i].owner) {
                return uint256(accounts[i].balance);
            }
        }
        return 0;
    }

    // Send value amount of tokens to address to.
    function transfer(address to, uint256 value) returns (bool success) {
        makeTransfer(uint256(getAccountNumber(msg.sender)), value, uint256(getAccountNumber(to)), "");
        return true;
    }

    // Unsupported
    //
    // Send value amount of tokens from address from to address to.
    function transferFrom(address from, address to, uint256 value) returns (bool success) {
        return false;
    }

    // Unsupported
    //
    // Allow spender to withdraw from your account, multiple times, up to the
    // value amount. If this function is called again it overwrites the current
    // allowance with value.
    function approve(address spender, uint256 value) returns (bool success) {
        return false;
    }

    // Unsupported
    //
    // Returns the amount which spender is still allowed to withdraw from owner.
    function allowance(address owner, address spender) constant returns (uint256 remaining) {
        return 0;
    }


    /* User functions: */

    // Anyone can open an account, which will be associated to a public address
    function openAccount() notPaused returns (uint256 accountNumber) {
        int256 acct = getAccountNumber(msg.sender);
        if(acct >= 0)
            return uint256(acct);
        accounts.push(Account(true, msg.sender, 0, 0, false));
        accountNumber = accounts.length - 1;
        accountByOwner[msg.sender] = accountNumber;
        return accountNumber;
    }

    // message field for reference purposes only - although it will not have any effect in the transaction
    // itself, it will be stored in the blockchain and therefore will be available to be used as reference
    // for subsequent actions
    function makeTransfer(uint256 sender, uint256 amount, uint256 receiver, bytes32 message)
            senderOnly(sender)
            notBlocked(sender)
            notBlocked(receiver)
            accountExists(receiver)
            notPaused
            returns (bool success) {
        uint256 fees = (feePerMillion * amount) / 1000000;
        if(fees > maxFee) {
            fees = maxFee;
        }
        if(accounts[sender].balance + int256(accounts[sender].overdraft) >= int256(amount)) {
            accounts[sender].balance -= int256(amount);
            accounts[receiver].balance += int256(amount - fees);
            accounts[0].balance += int256(fees);
            Transfer(accounts[sender].owner, accounts[receiver].owner, uint256(amount));
            return true;
        } else {
            throw;
        }
    }

    function redeemFunds(uint256 sender, uint256 funds, uint256 redemptionMode,
                         bytes32 routingInfo)
            accountExists(sender)
            senderOnly(sender)
            notPaused {
        if(accounts[sender].balance + int256(accounts[sender].overdraft) >= int256(funds)) {
            accounts[sender].balance -= int256(funds);
            accounts[0].balance += int256(funds);
        } else {
            throw;
        }
    }

    // Different redemption modes to be used in redeemFunds.
    uint256 constant REDEMPTION_MODE_UNKNOWN           = 0;
    uint256 constant REDEMPTION_MODE_REFER_TO_TRANSFER = 1;
    uint256 constant REDEMPTION_MODE_ROUTE_TO_ACCOUNT  = 2;
    uint256 constant REDEMPTION_MODE_RETURN_PAYMENT    = 3;

    // Result codes for redemptions.
    uint256 constant REDEMPTION_SUCCESS                 = 0;
    uint256 constant REDEMPTION_USER_UNKNOWN_TO_BANK    = 1;
    uint256 constant REDEMPTION_BANK_ACCOUNT_NOT_FOUND  = 2;
    uint256 constant REDEMPTION_BANK_TRANSFER_FAILED    = 3;
    uint256 constant REDEMPTION_CASHOUT_LIMIT_EXCEEDED  = 4;
    uint256 constant REDEMPTION_PAYMENT_FAILED          = 5;
    uint256 constant REDEMPTION_UNKNOWN_REDEMPTION_MODE = 6;
    uint256 constant REDEMPTION_FAILED_UNSPECIFIED      = 7;


    /* Backoffice functions: */

    // Change the name of this bank.
    function setBankName(bytes32 _bankName) bankOnly {
        bankName = _bankName;
    }

    // Update the fee policy of this bank.
    function setFees(uint256 _feePerMillion, uint256 _maxFee) bankOnly {
        feePerMillion = _feePerMillion;
        maxFee = _maxFee;
    }

    // Add new funds to the given account.
    function addFunds(uint256 account, uint256 funds) bankOnly accountExists(account) {
        accounts[account].balance += int256(funds);
    }

    // Remove funds from the given account.
    function removeFunds(uint256 account, uint256 funds, uint256 redemptionHash, uint256 errorCode)
            bankOnly accountExists(account) {
        if(accounts[account].balance + int256(accounts[account].overdraft) >= int256(funds)) {
            accounts[account].balance -= int256(funds);
        } else {
            throw;
        }
    }

    // Change the overdraft allowance for the given account.
    function setOverdraft(uint256 account, uint256 limit) bankOnly accountExists(account) {
        accounts[account].overdraft = limit;
    }

    // Block the given account.
    function blockAccount(uint256 account) bankOnly accountExists(account) {
        accounts[account].blocked = true;
    }

    // Unblock the given account.
    function unblockAccount(uint256 account) bankOnly accountExists(account) {
        accounts[account].blocked = false;
    }

    function pause_for_maintenance() bankOnly {
        pausedForMaintenance = true;
    }

    function resume() bankOnly {
        pausedForMaintenance = false;
    }


    /* Public system info functions */

    // Get the account number of the account associated with the given address.
    function getAccountNumber(address user) constant returns (int256) {
        uint256 nb = accountByOwner[user];
        if (nb == 0) {
            // account does not exist
            return -1;
        } else {
            return int256(nb);
        }
    }

    // Get the total number of accounts.
    function numberOfAccounts() constant returns (uint256) {
        return accounts.length;
    }

    /* Special functions */

    // Close the bank.
    function closeDown() bankOnly {
        selfdestruct(bank);
    }

    // Change the address of the bank.
    function changeBankAddress(address newAddress) bankOnly {
        bank = newAddress;
    }

    function () { throw; }

}
