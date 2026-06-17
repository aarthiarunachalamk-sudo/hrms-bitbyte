const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');
const path = require('path');

// Read environment variables
const bucketName = process.env.AWS_S3_BUCKET_NAME;
const region = process.env.AWS_REGION;
const accessKeyId = process.env.AWS_ACCESS_KEY_ID;
const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;

// Check if S3 credentials are configured
const isS3Configured = !!(bucketName && region && accessKeyId && secretAccessKey);

let s3Client = null;
if (isS3Configured) {
  try {
    s3Client = new S3Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });
    console.log('✅ AWS S3 Client initialized.');
  } catch (err) {
    console.error('❌ Failed to initialize S3 Client, using local fallback:', err.message);
  }
} else {
  console.log('⚠️  AWS S3 not fully configured. File uploads will use local folder fallback.');
}

/**
 * Uploads a file (selfie buffer) to S3, falling back to local file storage.
 * @param {Object} file Multer file object
 * @param {string|number} employeeId The ID of the employee
 * @param {string} eventType 'check_in' or 'check_out'
 * @returns {Promise<string>} The uploaded file URL (S3 URL or relative local path)
 */
async function uploadSelfie(file, employeeId, eventType) {
  if (!file || !file.buffer) {
    throw new Error('No file buffer provided for upload');
  }

  const fileExt = path.extname(file.originalname) || '.jpg';
  const fileName = `selfie_${employeeId}_${eventType}_${Date.now()}${fileExt}`;

  // If S3 is configured, upload to S3
  if (isS3Configured && s3Client) {
    try {
      const command = new PutObjectCommand({
        Bucket: bucketName,
        Key: fileName,
        Body: file.buffer,
        ContentType: file.mimetype,
      });

      await s3Client.send(command);
      const s3Url = `https://${bucketName}.s3.${region}.amazonaws.com/${fileName}`;
      console.log(`🌐 Selfie uploaded to S3: ${s3Url}`);
      return s3Url;
    } catch (err) {
      console.error('❌ S3 upload failed, falling back to local disk:', err.message);
    }
  }

  // Fallback: Save locally
  try {
    const uploadsDir = path.join(__dirname, '../../uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    const filePath = path.join(uploadsDir, fileName);
    await fs.promises.writeFile(filePath, file.buffer);
    
    // Return a relative path, which the client can prepend its baseUrl to
    const localUrl = `/uploads/${fileName}`;
    console.log(`📁 Selfie saved locally: ${localUrl}`);
    return localUrl;
  } catch (err) {
    console.error('❌ Local file save failed:', err.message);
    throw new Error(`Upload failed: ${err.message}`);
  }
}

module.exports = {
  uploadSelfie,
};
