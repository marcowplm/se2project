/********** CLASSES **********/

sig Queue { 
	first: one AvailableTaxiDriver 
}


abstract sig TaxiDriver {}

sig AvailableTaxiDriver extends TaxiDriver {
	next: lone AvailableTaxiDriver
}

sig BusyTaxiDriver extends TaxiDriver {}


abstract sig Passenger {} 

sig PassengerOnRide extends Passenger {}

sig RequestingPassenger extends Passenger {]


abstract sig Ride {
	driver : one BusyTaxiDriver,
	passenger : some Passenger
} 

sig SharedRide extends Ride {
} {
	#passenger < 4
}

sig SingleRide extends Ride { }
{ 
	#passenger = 1
}


// what's the difference between Reservation and Request!?
sig Reservation {
	requester : one RequestingPassenger
	associatedRide : one Ride
}

sig Request {
	requester : one RequestingPassenger
	associatedRide
}


/********** CONSTRAINTS **********/

// ensures that no taxi driver is the subsequent of himself inside a queue
fact nextNotReflexive { no n:TaxiDriver | n = n.next }

// ensures that each taxi driver is associated to only one queue
fact onlyOneQueuePerAvailableTaxiDriver {
	all d:AvailableTaxiDriver | one q:Queue | d in q.first.*next 
}

// ensures that the last taxi driver of the queue exists and is unique
fact notCyclicQueue { 
	no d:TaxiDriver | d in d.^next 
}

// ensures that all taxi drivers marked as busy are making only one ride
fact AllBusyTaxiDriverAreInARide {
	all d:BusyTaxiDriver | one r:Ride | r.driver = d
}
	
// ensures that all passengers MARKED AS BUSY (DO WE HAVE BUSY PASSENGERS!?) are in a single ride
fact AllBusyPassengersAreInARide {
	all p:PassengerOnRide | one r:Ride | r.passenger = p	
}


/********** ASSERTIONS **********/

// check that every taxi driver belong to one queue only
assert UniqueQueuePerTaxiDriver {
	no disj q1, q2:Queue | one d:AvailableTaxiDriver | (d in q1.first.*next and d in q2.first.*next)
}

check UniqueQueuePerTaxiDriver

// check that every busy taxi driver is making only one ride
assert OnlyOneRidePerTaxiDriver {
	no disj r1, r2 : Ride | one d : BusyTaxiDriver | (d = r1.driver and d = r2.driver)
}

check OnlyOneRidePerTaxiDriver

// check that every passenger in a ride is in only one ride
assert OnlyOneRidePerPassenger {
	no disj r1, r2 : Ride | one p : PassengerOnRide | (p = r1.passenger and p = r2.passenger)
}

check OnlyOneRidePerPassenger

/********** PREDICATES **********/
pred show() {}

run show for 10

pred showRides() {
	#Ride>1
}

run showRides for 10
