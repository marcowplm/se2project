/*************** CLASSES ***************/

sig Queue { 
	first: one AvailableTaxiDriver,
	cityArea : one Location 
}

abstract sig TaxiDriver {}

sig AvailableTaxiDriver extends TaxiDriver {
	next: lone AvailableTaxiDriver
}

sig BusyTaxiDriver extends TaxiDriver {}

sig Passenger {} 

sig Ride {
	driver : one BusyTaxiDriver,
	passenger : some Passenger
} {
	#passenger < 4 && #passenger > 2 // <------- Be careful!
}

sig Location {}

sig ReservationRequest {
	requester : one Passenger,
	origin : one Location,
	destination : one Location,
	associatedRide : one Ride
} {
	origin != destination
}


	

/*************** CONSTRAINTS ***************/

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

// ensures that all passengers in a ride are in only one ride
fact OnlyOneRidePerTimePerPassenger {
	all disj r1, r2:Ride | disj[r1.passenger, r2.passenger]
}

// ensures that a passenger does only one request /reservation per time
fact OnlyOneRequestReservationPerTimePerPassenger {
	all disj rr1, rr2 : ReservationRequest | rr1.requester != rr2.requester
}

// ensures that a passenger requesting a taxi drive is not making a ride and viceversa
fact SameRequesterAndRider {
	all rr:ReservationRequest | rr.requester in rr.associatedRide.passenger 
}

/*************** ASSERTIONS ***************/

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
	no disj r1, r2 : Ride | not disj[r1.passenger, r2.passenger]
}
check OnlyOneRidePerPassenger

// check that origin and destination for a request / reservation are different
assert OriginAndDestinationAreDifferent {
	no rr: ReservationRequest | rr.origin = rr.destination 
}
check OriginAndDestinationAreDifferent

// check that a passenger does only one request /reservation per time
assert NoDuplicateRequestsAndReserves {
	no disj rr1, rr2: ReservationRequest | rr1.requester = rr2.requester
}
check NoDuplicateRequestsAndReserves

//check that if a passenger does a request, then he is one of the passengers of the associated ride
assert ReserverRequesterDoesRide {
	no rr:ReservationRequest | rr.requester not in rr.associatedRide.passenger
}
check ReserverRequesterDoesRide



/*************** PREDICATES ***************/
pred show() {}

run show for 7

pred showRides() {
	#Passenger>4
}

run showRides for 7 but exactly 2 Ride

pred showReservationsAndRequests() {
	#ReservationRequest > 1 
}

run showReservationsAndRequests for 6
