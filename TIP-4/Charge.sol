pragma ton-solidity >= 0.58.1;

contract Charge {
    mapping(bytes4 => uint32) private _ddcFees;

    event SetFee(address ddcAddr, bytes4 sig, uint32 amount);

    event DelFee(address ddcAddr,bytes4 sig);

    constructor()public {
        tvm.accept();
    }

    function queryFee(bytes4 sig) external view returns(uint) {
        return _ddcFees[sig];
    }

    function setFee(bytes4 sig, uint32 amount) external {
        tvm.accept();
        _ddcFees[sig] = amount;
        emit SetFee(address(this), sig, amount);
    }

    function delFee(bytes4 sig) external {
        tvm.accept();
        _ddcFees[sig] = 0;
        emit DelFee(address(this), sig);
    }
}
