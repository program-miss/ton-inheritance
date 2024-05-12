import "@stdlib/deploy";

// import "@stdlib/ownable";

message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}
// чтобы проверить хозяина контракта и запретить доступ в случае чего
trait Ownable {
    owner: Address;

     fun requireOwner() {
        // Если sender не равняется owner => ошибка с кодом 123
        nativeThrowUnless(123, sender() == self.owner);
    }

    get fun owner(): Address {
        return self.owner;
    }
}
message ChangeOwner {
    newOwner: Address;
}
// чтобы проверить хозяина контракта и запретить доступ в случае чего
// а также, чтобы изменить хозяина этого контракта
trait OwnableTransferable with Ownable {
    owner: Address;

    receive(msg: ChangeOwner){
        self.requireOwner();
        self.owner = msg.newOwner;
    }
}

// предпочтительнее использовать OwnableTransferable вместо Ownable
contract OwnableCounter with Deployable, OwnableTransferable {
    id: Int as uint32;
    counter: Int as uint32;
    owner: Address;
    init(id: Int){
        self.id = id;
        self.counter = 0;
        self.owner = sender();
    }

    receive(msg: Add){
        // сообщение будет приниматься только от кошелька owner
        self.requireOwner();
        self.counter += msg.amount;
    }

    get fun counter(): Int {
        return self.counter;
    }

    get fun id(): Int {
        return self.id;
    }
}
