// resume_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intern_management_app/api_key.dart';
import '../../../models/resume/resume_model.dart';

class ResumeService {
  // Gemini API key aur endpoint
  final String _apiKey = aiResumeAPIKey;
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=';

  // Resume generate karne ka function
  Future<String> generateResume(Resume resumeData) async {
    // 🔹 Prompt banaya gaya jo AI ko guide karega resume generate karne ke liye
    // 🔹 Important: Prompt me user ka diya gaya data improve kar ke return karna hai
    // 🔹 Dummy data add nahi karna, jo missing hai usko empty dena hai
    final prompt =
        """
     Response Rules:

Format: The output must be a single, complete, and valid JSON object. No markdown, headers, or extra text should be included before or after the JSON.

JSON Structure: The JSON object must adhere to the exact structure provided in the prompt, including nested arrays for workExperience, education, projects, and certifications.

Content Generation:

Act as an expert career consultant and professional resume writer.

Generate a highly professional, ATS-friendly, modern, and impactful resume.

Improve the provided candidate data to create a polished resume. Do not add any dummy data.

If a field (e.g., workExperience, projects, certifications, or education) is not provided by the user, return an empty array for that field.

Specific Formatting:

Professional Summary: The summary must be a single paragraph with justified alignment.

Descriptions: For skills, workExperience, education, and projects, use \n mean new line to represent bullet points without using actual bullet characters (•, -, *). The new lines should separate distinct points or skills.

Handling User Data:

Improve the provided candidate information.

Do not hallucinate or create any data that wasn't provided by the user.

Treat each request or chat as a separate entity. Do not carry over data from previous conversations.
meri baat suno ju data diya hai srif us ku improve karu khud sy kuch b add nahi karu
har chat ya prompt ku new chat ya prompt ky tur par lu har prompt ya chat ka previous prompt ya chat sy koi connection nahi.
ya tum br tag ku use kar rahu hu tumhe bola hai skills "Machine Learning: Supervised Learning, es trahan kar ky du aur /n ka matlb hai next line ma br tag use karny ka nahi bola samj ayi. ju instructions aur rules diya hai just unku  follow kar ky response du apny sy kuch kiya tu phir dekhna
      
      ### follow this structure it is just a structure dummy structure for you understanding:
{
  "name": "${resumeData.name}",
  "email": "${resumeData.email}",
  "mobile": "${resumeData.mobile}",
  "linkedin": "${resumeData.linkedin}",
  "twitter": "${resumeData.twitter}",
  "summary": "${resumeData.summary}",
  "skills": "Machine Learning: Supervised Learning, Unsupervised Learning, NLP, Computer Vision
  \nProgramming Languages: Python, Java
  \nDatabases/OS: MySQL, PostgreSQL, Linux, Windows, MacOS
  \nLibraries: Pandas, Numpy, Matplotlib, Scikit-learn, Pytorch, Tensorflow, Seaborn
  \nFrameworks/Tools: Power BI, Tableau, Flask, Hadoop, Git, Google Colab, Jupyter, Spyder
  \nSoft Skills: Critical Thinking, Problem-Solving, Effective Communication",",
  "languagesSpoken": "${resumeData.languagesSpoken}",
  "workExperience": [
    {
      "title": "Software Engineer",
      "company": "Tech Innovations Inc.",
      "startDate": "Jan 2022",
      "endDate": "Present",
      "description": "Developed and maintained scalable web applications using Flutter and Dart.
      \nImplemented new features and resolved bugs, improving application performance by 15%."
    }
  ],
  "education": [
    {
      "title": "Bachelor of Science in Computer Science",
      "university": "University of Engineering & Technology",
      "startDate": "Sep 2018",
      "endDate": "Aug 2022",
      "description": "Graduated with Honors.
      \nCompleted capstone project on machine learning."
    }
  ],
  "projects": [
    {
      "title": "Project Management Tool",
      "summary": "Created a full-stack project management application.
      \nIntegrated Firebase for real-time data synchronization and user authentication.",
      "projectLink": "https://github.com/my-user/project"
    }
  ],
  "certifications": [
    {
      "title": "AWS Certified Developer – Associate",
      "organization": "Amazon Web Services",
      "date": "Aug 2023",
      "link": "https://www.aws.com/certificate/xyz"
    }
  ]
}

      Candidate Information actual candidate information:ss
      Name: ${resumeData.name}
      Email: ${resumeData.email}
      Phone: ${resumeData.mobile}
      LinkedIn: ${resumeData.linkedin}
      Twitter: ${resumeData.twitter}
      Professional Summary: ${resumeData.summary}
      Skills: ${resumeData.skills}
      LanguagesSpoken: ${resumeData.languagesSpoken}
      Work Experience: ${resumeData.workExperience.map((e) => "Title: ${e.title}, Company: ${e.company}, Dates: ${e.startDate} – ${e.endDate}, Description: ${e.description}").join("\n")}
      Education: ${resumeData.education.map((e) => "Title: ${e.title}, University: ${e.university}, Dates: ${e.startDate} – ${e.endDate}, Description: ${e.description}").join("\n")}
      Projects: ${resumeData.projects.map((p) => "Title: ${p.title}, Summary: ${p.summary}, Link: ${p.projectLink}").join("\n")}
      Certifications: ${resumeData.certifications.map((c) => "Title: ${c.title}, Organization: ${c.organization}, Date: ${c.date}, Link: ${c.link}").join("\n")}
      """;

    try {
      // 🔹 Gemini API ko POST request bhejna
      final response = await http.post(
        Uri.parse('$_apiUrl$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}, // Prompt send kiya jata hai
              ],
            },
          ],

          // 🔹 Force AI to return JSON only
          "generationConfig": {"responseMimeType": "application/json"},
        }),
      );

      if (response.statusCode == 200) {
        // 🔹 Response parse karna
        final result = jsonDecode(response.body);
        final String generatedJson =
            result['candidates'][0]['content']['parts'][0]['text'];
        return generatedJson; // Final JSON return karna
      } else {
        throw Exception('Failed to generate resume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
