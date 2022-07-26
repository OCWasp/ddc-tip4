pragma ton-solidity >= 0.58.0;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../base/TIP4_1/TIP4_1Nft.sol';
import '../base/TIP4_2/TIP4_2Nft.sol';
import '../base/TIP4_3/TIP4_3Nft.sol';
import './interfaces/ITokenBurned.sol';

// interface ICollection{
//     function transferEvent(address operator, address from, address to, uint256 id) external;
//     function approvalEvent(address operator, address to, uint256 id) external;
//     function enterBlacklistEvent(address sender, uint256 ddcId) external;
//     function exitBlacklistEvent(address sender, uint256 ddcId) external;
//     function setURIEvent(address operator, uint256 ddcId, string ddcURI) external;
// }


contract Nft is TIP4_1Nft, TIP4_2Nft, TIP4_3Nft {

    uint128 private _executeFee = 0.3 ever;

    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        string json,
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex
    ) TIP4_1Nft(
        owner,
        sendGasTo,
        remainOnNft
    ) TIP4_2Nft (
        json
    ) TIP4_3Nft (
        indexDeployValue,
        indexDestroyValue,
        codeIndex
    ) public {
        tvm.accept();
    }

    function _beforeTransfer(
        address to,
        address sendGasTo,
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeTransfer(to, sendGasTo, callbacks);
    }

    function _afterTransfer(
        address to,
        address sendGasTo,
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterTransfer(to, sendGasTo, callbacks);
    }

    function _beforeChangeOwner(
        address oldOwner,
        address newOwner,
        address sendGasTo,
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function _afterChangeOwner(
        address oldOwner,
        address newOwner,
        address sendGasTo,
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function burn(address dest) external virtual onlyManager {
        require(isFreeze);
        tvm.accept();
        _destructIndex(dest);
        ITokenBurned(_collection).onTokenBurned(_id, _owner, _manager);
        selfdestruct(dest);

        ICollection(_collection).transferEvent{value: _executeFee, flag: 0}(msg.sender, _owner, address(0), _id);
    }

    function freeze() external virtual {
        tvm.accept();
        isFreeze = true;

        ICollection(_collection).enterBlacklistEvent{value: _executeFee, flag: 0}(msg.sender, _id);
    }

    function unFreeze() external virtual {
        tvm.accept();
        isFreeze = false;

        ICollection(_collection).exitBlacklistEvent{value: _executeFee, flag: 0}(msg.sender, _id);
    }

    function ddcURI() external virtual returns (string) {
        return _uri;
    }

    function setURI(string ddcURI) external virtual onlyManager {
        require(isFreeze);
        tvm.accept();
        _uri = ddcURI;

        ICollection(_collection).setURIEvent{value: _executeFee, flag: 0}(msg.sender,_id,ddcURI);
    }

    function approve(address to) external virtual onlyManager {
        tvm.accept();
        _approve = to;
        ICollection(_collection).approvalEvent{value: _executeFee, flag: 0}(msg.sender,to,_id);
    }

    function getApproved() external virtual returns (address) {
        return _approve;
    }
}