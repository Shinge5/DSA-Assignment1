// src/rental_server.bal
import ballerina/grpc;
import ballerina/time;
import 'generated.rental';  // From proto gen
import ballerina/io;

map<rental:Car> cars = {};  // Key: plate
map<rental:User> users = {};  // Key: id
map<CartItem[]> carts = {};  // Key: userId
map<Reservation[]> reservations = {};  // Key: userId

type CartItem record {|
    string plate;
    time:Utc startDate;
    time:Utc endDate;
    double dailyPrice;
|};

type Reservation record {|
    string plate;
    time:Utc startDate;
    time:Utc endDate;
    double totalPrice;
|};

listener grpc:Listener ep = new grpc:Listener(9090);

service rental:RentalService on ep {

    remote function addCar(rental:AddCarRequest req) returns rental:AddCarResponse {
        rental:Car newCar = {
            make: req.make,
            model: req.model,
            year: req.year,
            dailyPrice: req.dailyPrice,
            mileage: req.mileage,
            plate: req.plate,
            status: req.status
        };
        cars[req.plate] = newCar;
        return { plate: req.plate, message: "Car added" };
    }

    remote function createUsers(grpc:StreamingClient streamClient, grpc:Context context) returns rental:CreateUsersResponse|error {
        int count = 0;
        while true {
            var payload = streamClient->receive();
            if payload is Error {
                if payload is grpc:StreamingClientError {
                    break;
                }
                return payload;
            } else if payload is rental:User {
                users[payload.id] = payload;
                count += 1;
            }
        }
        return { count: count, message: "Users created" };
    }

    remote function updateCar(rental:UpdateCarRequest req) returns rental:UpdateCarResponse|error {
        if !cars.hasKey(req.plate) {
            return error("Car not found");
        }
        var car = cars.get(req.plate);
        if car is rental:Car {
            if req.dailyPrice > 0 {
                car.dailyPrice = req.dailyPrice;
            }
            if req.status != "" {
                car.status = req.status;
            }
            // Add other updates...
            cars[req.plate] = car;
        }
        return { message: "Car updated" };
    }

    remote function removeCar(rental:RemoveCarRequest req) returns rental:RemoveCarResponse {
        _ = cars.remove(req.plate);
        rental:Car[] carList = [];
        foreach var c in cars.values() {
            carList.push(c);
        }
        return { cars: carList };
    }

    remote function listAvailableCars(rental:ListCarsRequest req) returns stream<rental:Car, error?>|error {
        rental:Car[] available = [];
        foreach var car in cars.values() {
            if car.status == "AVAILABLE" {
                boolean matches = true;
                if req.filter != "" {
                    // Simple filter (extend for year etc.)
                    matches = car.make.contains(req.filter) || car.model.contains(req.filter);
                }
                if matches {
                    available.push(car);
                }
            }
        }
        return available.toStream();
    }

    remote function searchCar(rental:SearchCarRequest req) returns rental:SearchCarResponse {
        if cars.hasKey(req.plate) {
            var car = cars.get(req.plate);
            if car is rental:Car && car.status == "AVAILABLE" {
                return { car: car, available: true, message: "" };
            }
            return { car: car, available: false, message: "Not available" };
        }
        return { available: false, message: "Not found" };
    }

    remote function addToCart(rental:AddToCartRequest req) returns rental:AddToCartResponse|error {
        if !users.hasKey(req.userId) || users[req.userId].role != "CUSTOMER" {
            return error("Invalid user");
        }
        if !cars.hasKey(req.plate) {
            return error("Car not found");
        }
        var car = cars.get(req.plate);
        if car is rental:Car && car.status != "AVAILABLE" {
            return error("Car not available");
        }
        if req.startDate.toString() >= req.endDate.toString() {
            return error("Invalid dates");
        }

        CartItem item = {
            plate: req.plate,
            startDate: req.startDate,
            endDate: req.endDate,
            dailyPrice: car.dailyPrice
        };
        if !carts.hasKey(req.userId) {
            carts[req.userId] = [];
        }
        carts[req.userId].push(item);
        return { message: "Added to cart", success: true };
    }

    remote function placeReservation(rental:PlaceReservationRequest req) returns rental:PlaceReservationResponse|error {
        if !users.hasKey(req.userId) || users[req.userId].role != "CUSTOMER" {
            return error("Invalid user");
        }
        var cartItems = carts.get(req.userId);
        if cartItems is () || cartItems.length() == 0 {
            return error("Empty cart");
        }

        double total = 0;
        foreach var item in cartItems {
            // Check availability (simple: no overlap check impl; extend with date ranges)
            var car = cars.get(item.plate);
            if car is rental:Car && car.status == "AVAILABLE" {
                int days = check calculateDays(item.startDate, item.endDate);
                total += days * item.dailyPrice;
                // "Book" by setting UNAVAILABLE (simplified)
                car.status = "UNAVAILABLE";
                cars[item.plate] = car;
                // Add to reservations
                if !reservations.hasKey(req.userId) {
                    reservations[req.userId] = [];
                }
                reservations[req.userId].push({
                    plate: item.plate,
                    startDate: item.startDate,
                    endDate: item.endDate,
                    totalPrice: days * item.dailyPrice
                });
            } else {
                return error("Car no longer available: " + item.plate);
            }
        }

        // Clear cart
        carts.remove(req.userId);
        return { totalPrice: total, message: "Reservation placed", success: true };
    }
}

function calculateDays(time:Utc start, time:Utc end) returns int|error {
    int startSeconds = start.time;
    int endSeconds = end.time;
    return (endSeconds - startSeconds) / (24 * 60 * 60);  // Days
}