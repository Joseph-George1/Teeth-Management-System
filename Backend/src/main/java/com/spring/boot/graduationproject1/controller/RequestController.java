package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.service.RequestServices;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/request")
public class RequestController {

    @Autowired
    private RequestServices requestServices;

    @GetMapping("/getAllRequests")
    public ResponseEntity<List<RequestDto>> getAllRequests() {
        return ResponseEntity.ok(requestServices.getAllRequests());
    }

    @GetMapping("/getRequestById")
    public ResponseEntity<RequestDto> getRequestById(@RequestParam Long id) {
        return ResponseEntity.ok(requestServices.getRequestById(id));
    }

    @PostMapping("/createRequest")
    public ResponseEntity<RequestDto> createRequest(@RequestBody RequestDto requestDto) {
        return ResponseEntity.ok(requestServices.createRequest(requestDto));
    }

    @DeleteMapping("/deleteRequest")
    public ResponseEntity<Void> deleteRequest(Long id){
        requestServices.deleteRequest(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/getRequestByCategoryId")
    public ResponseEntity<List<RequestDto>>getRequestByCategoryId(@RequestParam Long categoryId){
        return ResponseEntity.ok(requestServices.getRequestByCategoryId(categoryId));
    }

    @GetMapping("/getRequestsByDoctorId")
    public ResponseEntity<List<RequestDto>> getRequestsByDoctorId(){
        return ResponseEntity.ok(requestServices.getRequestByDoctorId());
    }

    @PutMapping("/editRequest/{requestId}")
    public ResponseEntity<RequestDto> editRequest(
            @PathVariable Long requestId,
            @RequestBody RequestDto requestDto) {
        return ResponseEntity.ok(requestServices.editRequest(requestId, requestDto));
    }

    @PutMapping("/updateStatus/{requestId}")
    public ResponseEntity<Void> updateRequestStatus(
            @PathVariable Long requestId,
            @RequestParam String status) {
        requestServices.updateRequestStatus(requestId, status);
        return ResponseEntity.ok().build();
    }
}
