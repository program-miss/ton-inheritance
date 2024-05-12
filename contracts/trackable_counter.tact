import "@stdlib/deploy";
import "@stdlib/ownable";
message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}
trait Trackable with Ownable {
    numMessagesReceived: Int;
    owner: Address;
    // Виртуальные константы -
    // Абстрактные константы - мы можем не инициализировать,
    // инициализировать можем в самом контракте, который мы будем наследовать

    virtual const ENABLE_RESET: Bool = true;

     fun receiveNewMessage() {
        if (self.filterMessage()) {
            self.numMessagesReceived = (self.numMessagesReceived + 1);
        }
    }

    receive("reset stats"){
        if (self.ENABLE_RESET) {
            self.requireOwner();
            self.numMessagesReceived = 0;
            self.reply("reset done".asComment());
        }
    }

    get fun stats(): Int {
        return self.numMessagesReceived;
    }

    // virtual - для того, чтобы можно было переопределить логику этой функции

    virtual fun filterMessage(): Bool {
        if (sender() == self.owner()) {
            return false;
        }
        return true;
    }
}

// считает, сколько сообщений было отправлено вообще на смарт-контракт
contract TrackableCounter with Deployable, Trackable {
    id: Int as uint32;
    counter: Int as uint32;
    numMessagesReceived: Int as uint32;
    owner: Address;
    override const ENABLE_RESET: Bool = false;
    init(id: Int){
        self.id = id;
        self.counter = 0;
        self.numMessagesReceived = 0;
        self.owner = sender();
    }

    receive(msg: Add){
        self.receiveNewMessage();
        self.counter += msg.amount;
    }

    get fun counter(): Int {
        return self.counter;
    }

    get fun id(): Int {
        return self.id;
    }

    // чтобы переписать virtual функцию
    // полиморфизм
    // изменив функцию здесь, мы изменили ее и в Trackable trait выше

    override fun filterMessage(): Bool {
        return true;
    }
}
