# 🧪 Testing Guide - Add Permit Segment Feature

## 📱 Complete Testing Flow

### **Prerequisites**
- ✅ Backend API running at `http://10.10.20.111:8888/navigation/`
- ✅ Valid authentication token
- ✅ At least one route created with PERMIT 1

---

## 🎯 Test Scenario 1: Happy Path (With Existing Data)

### **Step 1: Navigate to Permit List**
1. Open app
2. Create a route with PERMIT 1 (via add_permit screen)
3. You should see "PERMIT 1" card in permit list

**Expected Result**: ✅ PERMIT 1 card visible with starting/ending points

---

### **Step 2: Click "ADD PERMIT SEGMENT"**
1. Locate the "+ ADD PERMIT SEGMENT" button below PERMIT 1 card
2. Click it

**Expected Result**: 
- ✅ Navigates to "ADD PERMIT SEGMENT" screen
- ✅ Shows loading indicator briefly
- ✅ Starting point field auto-filled with data from GET API

**Debug Logs to Check**:
```
🟢 [AddPermitSegmentController] onInit called!
📋 [AddPermitSegmentController] Route ID: 26
📋 [AddPermitSegmentController] Permit ID: 28
🔄 [FetchStartingPoint] Fetching data for route: 26
🌐 [FetchStartingPoint] GET URL: http://10.10.20.111:8888/navigation/starting-point/route/26/
✅ [FetchStartingPoint] Response Status: 200
✅ [FetchStartingPoint] Pre-filled starting point: Rock Rapids, Lyon County, Iowa
```

---

### **Step 3: Verify Starting Point Pre-filled**
**Check**:
- Starting Point field shows: "Rock Rapids, Lyon County, Iowa" (or your data)
- Field is editable (user can change if needed)

**Expected Result**: ✅ Starting point pre-filled from API

---

### **Step 4: Add Ending Point via Map**
1. Click map icon next to "Ending Point" field
2. Map dialog opens
3. Tap anywhere on the map
4. Orange circle marker appears at tapped location
5. Address appears at bottom
6. Click "CONFIRM"

**Expected Result**: 
- ✅ Map dialog opens
- ✅ Orange marker appears on tap
- ✅ Address fetched and displayed
- ✅ Ending point field filled with address

**Debug Logs**:
```
📍 [MapPicker] User tapped at: 43.5460, -96.7313
🗑️ [MapPicker] Cleared existing markers
📌 [MapPicker] Added orange circle marker at tapped location
✅ [MapPicker] Address resolved: Sioux Falls, SD, USA
```

---

### **Step 5: Optional - Add Document/Photo**
**Test Document Upload**:
1. Click document icon (Import)
2. Select a PDF/DOC file
3. Icon turns green with checkmark

**Test Camera**:
1. Click camera icon
2. Take a photo
3. Icon turns green with checkmark

**Test Voice Input**:
1. Click microphone icon
2. Speak an address
3. Click "ADD"
4. Address fills ending point field

**Expected Result**: ✅ All input methods work correctly

---

### **Step 6: Submit Segment**
1. Click "ADD SEGMENT" button
2. Button shows loading spinner
3. POST API call executes

**Expected Result**: 
- ✅ Loading spinner appears
- ✅ Success message: "Permit segment added successfully!"
- ✅ Navigates back to permit list
- ✅ PERMIT 2 appears in list

**Debug Logs**:
```
🚀 [UploadPermitSegment] Initiating segment upload...
🌐 [UploadPermitSegment] Target URL: http://10.10.20.111:8888/navigation/route/26/permit/
📦 [UploadPermitSegment] Fields: {start_location_name: Rock Rapids..., end_location_name: Sioux Falls...}
📤 [UploadPermitSegment] Sending request...
✅ [UploadPermitSegment] Response Status: 201
✅ [UploadPermitSegment] Extracted permit ID: 29
🏁 [UploadPermitSegment] Upload process finished.
```

---

### **Step 7: Verify Permit List Updated**
**Check Permit List Screen**:
- PERMIT 1 card visible
- PERMIT 2 card visible (newly added)
- Both show starting/ending points
- Both have "VIEW PERMIT" button

**Expected Result**: ✅ Both permits visible in list

---

### **Step 8: Test Preview Screen**
1. Click "PREVIEW" button at bottom
2. Preview screen opens with map

**Expected Result**: 
- ✅ Map shows all waypoints from PERMIT 1 and PERMIT 2
- ✅ Orange pins numbered 1, 2, 3, 4...
- ✅ Route line connects all points
- ✅ Distance calculated correctly

**Debug Logs**:
```
🔎 [PermitListScreen] onPreview clicked. permits count: 2
👉 Permit #0 ("PERMIT 1") allLatLngs count: 2
👉 Permit #1 ("PERMIT 2") allLatLngs count: 2
🔎 [PermitListScreen] Final allPoints generated for preview. Count: 4
```

---

### **Step 9: Test Drive Screen**
1. From preview screen, click "DRIVE"
2. Drive screen opens with navigation

**Expected Result**: 
- ✅ Map shows current location
- ✅ All waypoints visible
- ✅ Navigation instructions appear
- ✅ Can start driving

---

## 🎯 Test Scenario 2: No Existing Data

### **Step 1: Fresh Route (No Starting Point Data)**
1. Create a new route without starting point data
2. Click "ADD PERMIT SEGMENT"

**Expected Result**: 
- ✅ Screen opens
- ✅ GET API returns empty/error (no data)
- ✅ No error message shown to user
- ✅ Starting point field is empty
- ✅ User can input manually

**Debug Logs**:
```
🔄 [FetchStartingPoint] Fetching data for route: 27
⚠️ [FetchStartingPoint] No starting point data found, user can input manually
```

---

### **Step 2: Manual Input**
1. Click map icon for starting point
2. Pick location from map
3. Click map icon for ending point
4. Pick location from map
5. Click "ADD SEGMENT"

**Expected Result**: ✅ Segment created successfully even without pre-filled data

---

## 🎯 Test Scenario 3: Validation Errors

### **Test 1: Empty Starting Point**
1. Open add segment screen
2. Clear starting point field (if pre-filled)
3. Fill ending point
4. Click "ADD SEGMENT"

**Expected Result**: 
- ✅ Orange snackbar appears
- ✅ Message: "Starting Point is required. Please pick from map or enter manually."
- ✅ No API call made

---

### **Test 2: Empty Ending Point**
1. Fill starting point
2. Leave ending point empty
3. Click "ADD SEGMENT"

**Expected Result**: 
- ✅ Orange snackbar appears
- ✅ Message: "Ending Point is required. Please pick from map or enter manually."
- ✅ No API call made

---

## 🎯 Test Scenario 4: Network Errors

### **Test 1: No Internet**
1. Turn off WiFi/Mobile data
2. Try to add segment
3. Click "ADD SEGMENT"

**Expected Result**: 
- ✅ Red snackbar appears
- ✅ Message: "Network Error: [error details]"
- ✅ User can retry after reconnecting

---

### **Test 2: API Timeout**
1. Slow network connection
2. Click "ADD SEGMENT"
3. Wait for timeout

**Expected Result**: 
- ✅ Loading spinner shows
- ✅ After timeout, error message appears
- ✅ User can retry

---

## 🎯 Test Scenario 5: Map Picker

### **Test 1: Tap to Place Marker**
1. Open map picker
2. Tap different locations
3. Observe marker movement

**Expected Result**: 
- ✅ Previous marker clears
- ✅ New orange circle appears at tap location
- ✅ Address updates each time
- ✅ Smooth animation

---

### **Test 2: Drag Map**
1. Open map picker
2. Drag map around
3. Tap new location

**Expected Result**: 
- ✅ Map pans smoothly
- ✅ Marker placement works anywhere
- ✅ Zoom controls work

---

## 🎯 Test Scenario 6: Voice Input

### **Test 1: Voice Recognition**
1. Click microphone icon
2. Grant permission if asked
3. Speak clearly: "Sioux Falls South Dakota"
4. Click "ADD"

**Expected Result**: 
- ✅ Microphone animates (glowing effect)
- ✅ Text appears in real-time
- ✅ Text fills ending point field
- ✅ Can edit after voice input

---

### **Test 2: Cancel Voice Input**
1. Click microphone icon
2. Start speaking
3. Click "CANCEL"

**Expected Result**: 
- ✅ Dialog closes
- ✅ No text added to field
- ✅ Microphone stops listening

---

## 🎯 Test Scenario 7: File Uploads

### **Test 1: Document Upload**
1. Click document icon
2. Select PDF file
3. Verify icon turns green
4. Submit segment

**Expected Result**: 
- ✅ File picker opens
- ✅ PDF selected
- ✅ Icon shows checkmark
- ✅ File included in POST request

---

### **Test 2: Camera Photo**
1. Click camera icon
2. Grant permission
3. Take photo
4. Verify icon turns green
5. Submit segment

**Expected Result**: 
- ✅ Camera opens
- ✅ Photo captured
- ✅ Icon shows checkmark
- ✅ Photo included in POST request

---

## 🎯 Test Scenario 8: Multiple Segments

### **Test 1: Add 3+ Segments**
1. Create PERMIT 1
2. Add PERMIT 2 via segment
3. Add PERMIT 3 via segment
4. Add PERMIT 4 via segment

**Expected Result**: 
- ✅ All permits appear in list
- ✅ Each has unique data
- ✅ Preview shows all waypoints
- ✅ Drive navigation includes all

---

## 📊 API Response Validation

### **GET API Response Format**
```json
{
  "status": true,
  "data": {
    "start_location_name": "Rock Rapids, Lyon County, Iowa",
    "start_latitude": 43.4272798325066,
    "start_longitude": -96.17579784702897
  }
}
```

**Validation**:
- ✅ `status` is boolean
- ✅ `data` object exists
- ✅ All three fields present
- ✅ Coordinates are numbers

---

### **POST API Request Format**
```
POST /navigation/route/26/permit/
Content-Type: multipart/form-data

Fields:
- start_location_name: "Rock Rapids, Lyon County, Iowa"
- start_latitude: "43.4272798325066"
- start_longitude: "-96.17579784702897"
- end_location_name: "Sioux Falls, SD"
- end_latitude: "43.5460"
- end_longitude: "-96.7313"
- permit_file: [binary data] (optional)
```

**Validation**:
- ✅ All required fields present
- ✅ Coordinates as strings
- ✅ File attachment works
- ✅ Authorization header included

---

### **POST API Response Format**
```json
{
  "status": true,
  "data": {
    "id": 29,
    "route": 26,
    "start_location_name": "Rock Rapids, Lyon County, Iowa",
    "start_latitude": 43.4272798325066,
    "start_longitude": -96.17579784702897,
    "end_location_name": "Sioux Falls, SD",
    "end_latitude": 43.5460,
    "end_longitude": -96.7313,
    "permit_file": "http://...",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Validation**:
- ✅ `id` extracted correctly
- ✅ All data saved
- ✅ File URL returned (if uploaded)

---

## 🐛 Common Issues & Solutions

### **Issue 1: Starting Point Not Pre-filling**
**Symptoms**: Field remains empty even with GET API success

**Debug**:
1. Check console for GET API response
2. Verify `data.start_location_name` exists
3. Check if controller is properly initialized

**Solution**: Ensure GET API returns correct format

---

### **Issue 2: Map Marker Not Appearing**
**Symptoms**: Tap map but no marker shows

**Debug**:
1. Check console for "MapPicker" logs
2. Verify `clearCircles()` and `addCircle()` calls
3. Check map controller initialization

**Solution**: Ensure map is fully loaded before tapping

---

### **Issue 3: POST API Fails**
**Symptoms**: Error message after clicking "ADD SEGMENT"

**Debug**:
1. Check console for POST request details
2. Verify all required fields present
3. Check authorization token
4. Verify backend endpoint

**Solution**: Match request format with backend expectations

---

### **Issue 4: Permit List Not Refreshing**
**Symptoms**: New segment created but not visible in list

**Debug**:
1. Check if `addPermitFromApi()` called
2. Verify permit ID extracted from response
3. Check PermitListController state

**Solution**: Ensure controller refresh logic executes

---

## ✅ Final Checklist

Before marking as complete, verify:

- [ ] GET API fetches starting point correctly
- [ ] Starting point pre-fills when data exists
- [ ] User can input manually when no data
- [ ] Map picker shows orange circle markers
- [ ] Voice input works
- [ ] Camera captures photos
- [ ] Document picker selects files
- [ ] Validation prevents empty submissions
- [ ] POST API creates segment successfully
- [ ] Permit list refreshes with new segment
- [ ] Preview screen shows all permits
- [ ] Drive screen navigates correctly
- [ ] Error messages are user-friendly
- [ ] Loading indicators appear during API calls
- [ ] All debug logs print correctly
- [ ] No memory leaks (controllers disposed)
- [ ] UI matches add_permit.dart design
- [ ] Responsive on different screen sizes
- [ ] Works on both Android and iOS

---

## 🎉 Success Criteria

**Feature is complete when**:
1. ✅ User can add multiple permit segments
2. ✅ Each segment has unique starting/ending points
3. ✅ All segments appear in permit list
4. ✅ Preview shows all waypoints from all permits
5. ✅ Drive navigation includes all segments
6. ✅ No crashes or errors during normal use
7. ✅ Professional UI/UX matching existing screens

---

## 📞 Support

If tests fail:
1. Check debug logs in console
2. Verify API endpoints and response formats
3. Ensure all dependencies installed
4. Check route definitions in all_routes.dart
5. Verify controller imports and bindings

**Happy Testing!** 🚀
