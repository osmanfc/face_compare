
# Face Compare & OCR API Documentation

This document provides examples for using the **Face Compare** and **OCR Read** APIs in one place.

---

## 🔹 1. Face Compare API

Compare two face images and check similarity.

### **cURL Example**

```bash
curl --location 'https://server_ip:2025/verify/' \
  --form 'image1=@"/C:/Users/USER/Downloads/face1.jpeg"' \
  --form 'image2=@"/C:/Users/USER/Downloads/face2.jpeg"' \
  --form 'apikey="YOUR_API_KEY_HERE"'

response is 
{
  "match": true,
  "confidence": 92.5,
  "message": "Faces matched successfully."
}
```bash
curl --location 'https://server_ip:2025/ocr/' \
  --form 'image=@"/C:/Users/USER/Downloads/1757300399f.jpeg"' \
  --form 'type="v2"' \
  --form 'apikey="YOUR_API_KEY_HERE"'

  response is {
  "text": "Extracted text from the image",
  "success": true
}

