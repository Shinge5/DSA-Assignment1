// src/rental_client.bal
import ballerina/grpc;
import ballerina/io;
import 'generated.rental';
import ballerina/time;

grpc:Client grpcClient = check new grpc:Client("http://localhost:9090");

public function main() returns error? {
    // Example sequence: Add car, create users (stream 2), list available, add to cart, place resv
    io:println("=== gRPC Car Rental Demo ===");

    // 1. Add car (admin)
    rental:AddCarRequest = {
        make: "Toyota",
        model: "Camry",
        year: 2023,
        dailyPrice: 50.0,
        mileage: 10000,
        plate: "ABC123",
        status: "AVAILABLE"
    };
    var addRes = grpcClient->addCar(addReq);
    if addRes is rental:AddCarResponse {
        io:println("Added car: ", addRes.message);
    }

    // 2. Create users (stream)
    grpc:StreamingClient streamClient = check grpcClient->createUsersStreamingClient();
    rental:User user1 = { id: "U1", name: "Admin1", role: "ADMIN" };
    rental:User user2 = { id: "U2", name: "Cust1", role: "CUSTOMER" };
    check streamClient->send(user1);
    check streamClient->send(user2);
    check streamClient->complete();
    var usersRes = check streamClient->receive(rental:CreateUsersResponse);
    io:println("Created users: ", usersRes.message);

    // 3. List available (stream)
    rental:ListCarsRequest listReq = { filter: "Toyota" };
    var listRes = grpcClient->listAvailableCars(listReq);
    if listRes is stream<rental:Car, grpc:Error> {
        io:println("Available cars:");
        error? e = listRes.forEach(function(rental:Car car) returns error? {
            io:println("- " + car.make + " " + car.model + " (" + car.plate + ")");
        });
    }

    // 4. Search car
    rental:SearchCarRequest searchReq = { plate: "ABC123" };
    var searchRes = grpcClient->searchCar(searchReq);
    if searchRes is rental:SearchCarResponse {
        io:println("Search: ", searchRes.message, " Available: ", searchRes.available);
    }

    // 5. Add to cart (customer U2)
    time:Utc start = check time:utcFromString("2025-09-20T00:00:00Z");
    time:Utc end = check time:utcFromString("2025-09-25T00:00:00Z");
    rental:AddToCartRequest cartReq = { userId: "U2", plate: "ABC123", startDate: start, endDate: end };
    var cartRes = grpcClient->addToCart(cartReq);
    if cartRes is rental:AddToCartResponse {
        io:println("Cart: ", cartRes.message);
    }

    // 6. Place reservation
    rental:PlaceReservationRequest resvReq = { userId: "U2" };
    var resvRes = grpcClient->placeReservation(resvReq);
    if resvRes is rental:PlaceReservationResponse {
        io:println("Reservation: ", resvRes.message, " Total: $" + resvRes.totalPrice.toString());
    }

    // Interactive: Update car price
    string plate = io:readln("Enter plate to update: ");
    float price = check io:readlnFloat("Enter new price: ");
    rental:UpdateCarRequest updateReq = { plate: plate, dailyPrice: price };
    var updateRes = grpcClient->updateCar(updateReq);
    io:println("Update: ", check updateRes.message);

    // Remove car
    string removePlate = io:readln("Enter plate to remove: ");
    rental:RemoveCarRequest removeReq = { plate: removePlate };
    var removeRes = grpcClient->removeCar(removeReq);
    if removeRes is rental:RemoveCarResponse {
        io:println("Remaining cars: ", removeRes.cars.length().toString());
    }
}
