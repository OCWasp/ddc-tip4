pragma ton-solidity >= 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../base/TIP4_2/TIP4_2Collection.sol';
import '../base/TIP4_3/TIP4_3Collection.sol';
import '../base/access/OwnableExternal.sol';
import './interfaces/ITokenBurned.sol';
import './Nft.sol';
import '../Authority/interfaces/IAccount.sol';
import '../Charge/Charge.sol';
import '../Authority/FunctionAccessible.sol';


contract Collection is TIP4_2Collection, TIP4_3Collection, OwnableExternal, ITokenBurned, Charge, FunctionAccessible {

    /**
    * Errors
    **/
    uint8 constant sender_is_not_owner = 101;
    uint8 constant value_is_less_than_required = 102;
    uint8 constant sender_is_not_collection = 103;


    /**
    * event
    **/
    event Transfer(address operator, address from,address to, uint256 ddcId);

    event Approval(address operator,address to,uint256 ddcId);

    event EnterBlacklist(address sender,uint256 ddcId);

    event ExitBlacklist(address sender,uint256 ddcId);

    event SetURI(address operator,uint256 ddcId,string ddcURI);

    event SetNameAndSymbol(string name,string symbol);

    uint256 _balance;

    uint256 _balanceCount;

    uint128 _remainOnNft = 0.3 ever;

    uint128 _mintNftValue = _remainOnNft + 0.5 ever;

    uint128 _mintingFee = 0.1 ever;

    uint128 _lastTokenId;

    string _name;

    string _symbol;

    mapping(string => bytes4) _functionIds;

    
    constructor(
        TvmCell codeNft,
        TvmCell codeIndex,
        TvmCell codeIndexBasis,
        uint256 ownerPubkey,
        string json
    ) OwnableExternal(
        ownerPubkey
    ) TIP4_1Collection (
        codeNft
    ) TIP4_2Collection (
        json
    ) TIP4_3Collection (
        codeIndex,
        codeIndexBasis
    ) Charge () public {
        tvm.accept();
        // Charge(this).setFee(tvm.functionId(Collection.mintNft), 1);
        // Charge(this).setFee(tvm.functionId(Collection.bMintNft), 1);
        // Charge(this).setFee(tvm.functionId(TIP4_1Nft.transfer), 1);
        // Charge(this).setFee(tvm.functionId(TIP4_1Nft.changeOwner), 1);
        // Charge(this).setFee(tvm.functionId(TIP4_1Nft.changeManager), 1);
        // Charge(this).setFee(tvm.functionId(Nft.burn), 1);
        
        Charge(this).setFee("1", 1);
        Charge(this).setFee("2", 1);
        Charge(this).setFee("3", 1);
        Charge(this).setFee("4", 1);
        Charge(this).setFee("5", 1);
        Charge(this).setFee("6", 1);
        Charge(this).setFee("7", 1);
        Charge(this).setFee("8", 1);
    }

    function mint(
        address owner,
        string json
    ) external virtual {
        require(msg.value > _remainOnNft + _mintingFee + (2 * _indexDeployValue), value_is_less_than_required);
        /// reserve original_balance + _mintingFee 
        tvm.rawReserve(_mintingFee, 4);

        _totalSupply++;
        _lastTokenId++;
        uint256 id = _lastTokenId;

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        address nftAddr = new Nft{
            stateInit: stateNft,
            value: 0,
            flag: 128
        }(
            owner,
            msg.sender,
            _remainOnNft,
            json,
            _indexDeployValue,
            _indexDestroyValue,
            _codeIndex
        );

        emit NftCreated(
            id, 
            nftAddr,
            owner,
            msg.sender,
            msg.sender
        );

        emit Transfer(msg.sender,address(0),owner,id);
    }

    function mintNft(
        address owner,
        string json
    ) external virtual {
        require(msg.value > _remainOnNft + _mintingFee + (2 * _indexDeployValue), value_is_less_than_required);
        /// reserve original_balance + _mintingFee 
        tvm.rawReserve(_mintingFee, 4);

        _totalSupply++;
        _lastTokenId++;
        uint256 id = _lastTokenId;

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        address nftAddr = new Nft{
            stateInit: stateNft,
            value: 0,
            flag: 128
        }(
            owner,
            msg.sender,
            _remainOnNft,
            json,
            _indexDeployValue,
            _indexDestroyValue,
            _codeIndex
        );

        emit NftCreated(
            id, 
            nftAddr,
            owner,
            msg.sender,
            msg.sender
        );

        emit Transfer(msg.sender,address(0),owner,id);
    }

    function onTokenBurned(uint256 id, address owner, address manager) external override {
        require(msg.sender == _resolveNft(id));
        emit NftBurned(id, msg.sender, owner, manager);
        _totalSupply--;
    }

    function withdraw(address dest, uint128 value) external pure onlyOwner {
        tvm.accept();
        dest.transfer(value, true);
    }

    function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
        _remainOnNft = remainOnNft;
    }

    function _isOwner() internal override onlyOwner returns(bool){
        return true;
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override(TIP4_2Collection, TIP4_3Collection) pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Nft,
            varInit: {_id: id},
            code: code
        });
    }

    // function delDDC() external virtual onlyOwner {
    //     tvm.accept();
    //     _destructIndex(dest);
    //     ITokenBurned(_collection).onTokenBurned(_id, _owner, _manager);
    //     selfdestruct(dest);
    // }

    function deposit(uint amount, address gasTo) external virtual {
        require(amount > 0, 104);
        tvm.accept();
        _balance += amount;
        _balanceCount += amount;
    }

    function settlement(uint32 amount) external virtual {
        require(amount <= _balance, 104);
        tvm.accept();
        _balance -= amount;
    }

    function getBalance() external virtual returns (uint256) {
        return _balance;
    }

    function getBalanceCount() external virtual returns (uint256) {
        return _balanceCount;
    }

    function getLatestDDCId() external virtual returns (uint128) {
        return _lastTokenId;
    }

    function name() external virtual returns (string) {
        return _name;
    }
    
    function symbol() external virtual returns (string) {
        return _symbol;
    }

    function setNameAndSymbol(string name, string symbol) external virtual onlyOwner {
        tvm.accept();
        _name = name;
        _symbol = symbol;

        emit SetNameAndSymbol(name, symbol);
    }


    function getFunctionIds(string functionName) external virtual returns (bytes4) {
        // functionIds['mintNft'] = tvm.functionId(Collection.mintNft);
        // functionIds['bMintNft'] = tvm.functionId(Collection.bMintNft);
        // functionIds['transfer'] = tvm.functionId(TIP4_1Nft.transfer);
        // functionIds['changeOwner'] = tvm.functionId(TIP4_1Nft.changeOwner);
        // functionIds['changeManager'] = tvm.functionId(TIP4_1Nft.changeManager);
        // functionIds['burn'] = tvm.functionId(Nft.burn);

        _functionIds['mintNft'] = "1";
        _functionIds['bMintNft'] = "2";
        _functionIds['transfer'] = "3";
        _functionIds['changeOwner'] = "4";
        _functionIds['changeManager'] = "5";
        _functionIds['burn'] = "6";
        _functionIds['approve'] = "7";
        _functionIds['setApprovalForAll'] = "8";

        return _functionIds[functionName];
    }

    function transferEvent(address operator, address from, address to, uint256 ddcId) external {
        emit Transfer(operator, from, to, ddcId);
    }

    function approvalEvent(address operator, address to, uint256 ddcId) external {
        emit Approval(operator, to, ddcId);
    }

    function enterBlacklistEvent(address sender, uint256 ddcId) external {
        emit EnterBlacklist(sender, ddcId);
    }

    function exitBlacklistEvent(address sender, uint256 ddcId) external {
        emit ExitBlacklist(sender, ddcId);
    }

    function setURIEvent(address operator, uint256 ddcId, string ddcURI) external {
        emit SetURI(operator, ddcId, ddcURI);
    }
}
