from datetime import datetime
# import SMBus
import smbus
import time
import firebase_admin
import google.cloud
from firebase_admin import credentials, firestore

# Credentials and Firebase App initialization. Always required
firCredentials = credentials.Certificate("./ServiceAccountKey.json")
firApp = firebase_admin.initialize_app(firCredentials)

# Get access to Firestore
firStore = firestore.client()

# Get access to the collections
# The ‘u’ prior to strings means a Unicode string. This is required for Firebase
firRGBCollectionRef = firStore.collection(u'rgbData')
firTempCollectionRef = firStore.collection(u'tempData')
firCurrentCollectionRef = firStore.collection(u'currentValues')

# Address of the temperature sensor on the i2c buss
TEMP_ADDRESS = 0x60
RGB_ADDRESS = 0x29
RGB_VERSION = 0x44
# Setup SMBus
bus = smbus.SMBus(1)
# Enable Temp Sensor
bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9)
bus.write_byte_data(TEMP_ADDRESS, 0x13, 0x07)
bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9)
# Enable Color Sensor
rgbEnabled = False
bus.write_byte(RGB_ADDRESS, 0x80 | 0x12)
ver = bus.read_byte(RGB_ADDRESS)
if ver == RGB_VERSION:
    rgbEnabled = True
    bus.write_byte(RGB_ADDRESS, 0x80 | 0x00)
    bus.write_byte(RGB_ADDRESS, 0x01 | 0x02)
    bus.write_byte(RGB_ADDRESS, 0x80 | 0x14)
# Give sensor a 5 second to initialize
time.sleep(5)
#Sensor Name
sensorName = "Sensor 1"
try:
    while 1:
        if rgbEnabled:
            print('Getting RGB data')
            data = bus.read_i2c_block_data(RGB_ADDRESS, 0)
            clear = data[1] << 8 | data[0]
            red = data[3] << 8 | data[2]
            green = data[5] << 8 | data[4]
            blue = data[7] << 8 | data[6]
            print("Red: ", red, " Green: ", green, " Blue: ", blue)

            #Creating new RGB Object
            newRGBData = {
                "sensorName": sensorName,
                "timeStamp": str(datetime.now().strftime('%Y-%m-%d %H:%M:%S')),
                "red": str(red),
                "green": str(green),
                "blue": str(blue)
            }

            # save color data to firebase
            firRGBCollectionRef.add(newRGBData)
        else:
            print('Failed to load')
            break
        
        print("")
        print('Getting Temperature data')
        #Getting temperature data
        tempData = bus.read_i2c_block_data(TEMP_ADDRESS, 0x00, 6)
        clear = ((tempData[4] * 256) + (tempData[5] & 0xF0)) / 16
        tempCel = clear / 16
        print("Temperature: ", tempCel, "C")

        # Air pressure - Reference: instructables.com/id/Personal-Electronics-Altimeter-Using-Raspberry-Pi/
        data = bus.read_i2c_block_data(TEMP_ADDRESS, 0x00, 4)
        pres = ((data[1] * 65536) + (data[2] * 256) + (data[3] & 0xF0)) / 16
        pressure = (pres / 4.0) / 1000.0
        print("Pressure: %.2f" % (pressure), "kpa")

        #Rounding the pressure and temperature values
        pressureString = "%.1f" % (pressure)
        temperatureString = "%.1f" % (tempCel)
        
        # write data into file
        outputData = open("tempAndRGBData.txt", "a+")
        colorWriteData = "Red: " + str(red) + " Green: " + str(green) + " Blue: " + str(blue) + "\n"
        temperatureWriteData = "Temperature: " + temperatureString + " C Pressure: " + pressureString + " kpa \n"
        outputData.write(sensorName + " TimeStamp: "+ str(datetime.now().strftime('%Y-%m-%d %H:%M:%S')) + "\n" + colorWriteData + temperatureWriteData + "\n")
        outputData.close()
        
        # Create new temperature object
        newTempData = {
            "sensorName": sensorName,
            "timeStamp": str(datetime.now().strftime('%Y-%m-%d %H:%M:%S')),
            "temperature": temperatureString,
            "pressure": pressureString
        }
        
        #Add to the firebase
        firTempCollectionRef.add(newTempData)
        
        #Create new current value object
        newCurrentValue = {
            "timeStamp": str(datetime.now().strftime('%Y-%m-%d %H:%M:%S')),
            "temperature": temperatureString,
            "pressure": pressureString,
            "red": str(red),
            "green": str(green),
            "blue": str(blue)
        }
        
        #Add to the database
        firCurrentCollectionRef.document('updatingValues').update(newCurrentValue)
        print("")
        #Wait time for 3 seconds
        time.sleep(10)

except KeyboardInterrupt:
    #Close the file if not closed
    outputData.close()
    print('Program exiting')
